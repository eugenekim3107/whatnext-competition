from typing import List, Optional, Dict
from rapidfuzz import process, fuzz
import uuid
from enum import Enum
from pymongo.collection import Collection
import pytz
from datetime import datetime, timedelta
import json

from pydantic.v1 import Field, validator
from langchain.pydantic_v1 import BaseModel
from langchain.tools import StructuredTool
from langchain_mistralai import ChatMistralAI
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.prompts.chat import MessagesPlaceholder, HumanMessagePromptTemplate, PromptTemplate
from langchain_community.chat_message_histories import RedisChatMessageHistory
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_core.output_parsers import CommaSeparatedListOutputParser
from langchain_core.messages import HumanMessage

##############
### Models ###
##############

class LocationInfoCondensed(BaseModel):
    name: str
    address: str
    stars: int
    review_count: int
    cur_open: int
    price: int
    phone: str
    summary: str
    tags: List[str]

class LocationInfoFunctionReturn(BaseModel):
    business_name: str
    content: str

class LocationNameInput(BaseModel):
    business_name: str = Field(..., description="Should be the name of a business.")

    @validator('business_name')
    def business_name_must_be_str(cls, v):
        if not isinstance(v, str):
            raise ValueError('business_name must be a string')
        return v
    
class LocationNameOutputList(BaseModel):
    business_names: List[str] = Field(..., description="A list of business names.")

class SortByEnum(str, Enum):
    review_count = "review_count"
    price = "price"
    rating = "stars"
    distance = "distance"
    llmsort = "llmsort"

class CurOpenEnum(int, Enum):
    all = 0
    open = 1

class NearbyLocationInput(BaseModel):
    tags: List[str] = Field(default=["all"], description="List of tags to filter locations. Default is ['all'].")
    radius: float = Field(default=10000, description="Search radius in meters. Must be between 5,000 and 20,000 meters.")
    limit: int = Field(default=5, description="Maximum number of locations to return. Must be between 1 and 30.")
    cur_open: CurOpenEnum = Field(default=CurOpenEnum.open, description="Filter for currently open locations (1 is currently open and 0 is all). Default is 1 (currently open).")
    sort_by: SortByEnum = Field(default=SortByEnum.llmsort, description="Criterion to sort the results. Default is 'review_count'.")

    @validator('radius')
    def radius_must_be_in_range(cls, v):
        if v < 5000 or v > 20000:
            return 10000
        return v
    
    @validator('limit')
    def limit_must_be_in_range(cls, v):
        if v < 1 or v > 30:
            return 5
        return v
    
    @validator('cur_open')
    def cur_open_must_be_valid(cls, v):
        if v not in [0,1]:
            return 0
        return v
    
    @validator('sort_by')
    def sort_by_must_be_valid(cls, v):
        if v not in ["review_count", "price", "stars", "distance", "llmsort"]:
            return "llmsort"
        return v

##########################
### Session management ###
##########################

def get_session_history(session_id: str, redis_url: str, key_prefix: str = "chat_history") -> RedisChatMessageHistory:
    memory = RedisChatMessageHistory(session_id, redis_url, key_prefix=key_prefix, ttl=3600)
    return memory

def delete_session_id(session_id: str, redis_url: str, key_prefix: str = "chat_history") -> None:
    memory = RedisChatMessageHistory(session_id, redis_url, key_prefix=key_prefix, ttl=3600)
    memory.clear()

def add_message_to_session_id(message: str, session_id: str, redis_url: str, key_prefix: str = "chat_history") -> None:
    memory = RedisChatMessageHistory(session_id, redis_url, key_prefix=key_prefix, ttl=3600)
    memory.add_message(HumanMessage(message))

def generate_session_id() -> str:
    return str(uuid.uuid4())

def get_session_ids(redis_client, key_prefix: str = "chat_history") -> List[str]:
    keys = redis_client.keys(f"{key_prefix}*")
    session_ids = []
    for key in keys:
        decoded_key = key.decode("utf-8")
        if key_prefix in decoded_key:
            session_id = decoded_key.split(key_prefix)[1]
            session_ids.append(session_id)
    return session_ids

def get_session_messages(session_id: str, redis_url: str, key_prefix: str = "chat_history"):
    memory = RedisChatMessageHistory(session_id, redis_url, key_prefix=key_prefix, ttl=3600)
    return memory.messages

########################
### Helper functions ###
########################

def search_tag_by_name(tag_names: List[str], collection: Collection) -> List[str]:
    # Retrieve all tags from the collection
    tags = collection.distinct("tags")
    
    matched_tags = []
    for tag_name in tag_names:
        best_match = process.extractOne(tag_name, tags, scorer=fuzz.ratio)
        if best_match:
            matched_tags.append(best_match[0])
    
    return matched_tags

def search_location_by_name(business_name: str, collection: Collection) -> Optional[Dict]:
    # Retrieve all business names from the collection
    businesses = collection.find({}, {"name": 1})
    business_names = [business["name"] for business in businesses]

    # Find the best match for the given business name
    best_match = process.extractOne(business_name, business_names, scorer=fuzz.ratio)
    
    if best_match:
        matched_name = best_match[0]
        # Retrieve the corresponding document from the collection
        matched_business = collection.find_one(
            {"name": matched_name},
            {
                "_id": 0,
                "business_id": 1,
                "name": 1,
                "image_url": 1,
                "address": 1,
                "stars": 1,
                "review_count": 1,
                "cur_open": 1,
                # "price": 1,
                "phone": 1,
                "display_phone": 1,
                "summary": 1,
                "tags": 1,
                "hours": 1,
                "location": 1,
            }
        )
        return matched_business

    return None

def is_within_hours(now, hours):
    if not hours or not isinstance(hours, list) or len(hours) != 2:
        return False
    open_time_str, close_time_str = hours
    open_hour, open_minute = int(open_time_str[:2]), int(open_time_str[2:])
    close_hour, close_minute = int(close_time_str[:2]), int(close_time_str[2:])

    open_time = now.replace(hour=open_hour, minute=open_minute, second=0, microsecond=0)
    close_time = now.replace(hour=close_hour, minute=close_minute, second=0, microsecond=0)

    if close_time <= open_time:
        close_time += timedelta(days=1)

    return open_time <= now <= close_time

######################
### Tool functions ###
######################

def get_location_recommendations(latitude: float,
                                 longitude: float,
                                 tags: Optional[List[str]],
                                 radius: Optional[float],
                                 limit: Optional[int],
                                 cur_open: Optional[int],
                                 sort_by: Optional[str],
                                 locations_db: Collection,
                                 session_id: str,
                                 redis_url: str,
                                 sort_model) -> List[Optional[str]]:
    """Retrieve location recommendations based on user preferences."""
    matched_tags = search_tag_by_name(tags, locations_db)
    print(matched_tags)
    print(latitude, longitude, tags, radius, limit, cur_open, sort_by, locations_db, session_id, cur_open)
    query_base = [
        {
            "$geoNear": {
                "near": {
                    "type": "Point",
                    "coordinates": [longitude, latitude]
                },
                "distanceField": "dist.calculated",
                "maxDistance": radius,
                "query": {
                    "tags": {"$in": matched_tags}
                },
                "spherical": True
            }
        },
        {
            "$addFields": {
                "matched_tags_count": {
                    "$size": {
                        "$setIntersection": ["$tags", matched_tags]
                    }
                }
            }
        },
        {
            "$match": {
                "matched_tags_count": {"$gt": 0}
            }
        },
        {
            "$limit": 15
        },
        {
            "$project": {
                "_id": 0,
                "name": 1,
                "location": 1,
                "address": 1,
                "stars": 1,
                "review_count": 1,
                "price": 1,
                "phone": 1,
                "summary": 1,
                "tags": 1,
                "hours": 1
            }
        }
    ]

    pacific = pytz.timezone('America/Los_Angeles')
    now_utc = datetime.now(pytz.utc)
    now = now_utc.astimezone(pacific)

    sort_criteria = {
        "matched_tags_count": -1
    }

    if sort_by in ["stars", "review_count", "price"]:
        sort_criteria[sort_by] = -1 if sort_by != "price" else 1
        query_base.insert(-1, {"$sort": sort_criteria})
        output_businesses_final = list(locations_db.aggregate(query_base))

    elif sort_by == "distance":
        sort_criteria["dist.calculated"] = 1
        query_base.insert(-1, {"$sort": sort_criteria})
        output_businesses_final = list(locations_db.aggregate(query_base))

    else:
        query_base.insert(-1, {"$sort": sort_criteria})
        output_businesses_temp = list(locations_db.aggregate(query_base))
        sorted_business_names = []
        if len(output_businesses_temp) > 0:
            sorted_business_names = sort_model.invoke(
                {
                    "chat_history": get_session_messages(session_id, redis_url),
                    "list_of_locations": json.dumps(output_businesses_temp),
                    "input": get_session_messages(session_id, redis_url, key_prefix="input")[0].content,
                }
            )
        output_businesses_final = []
        for business_name in sorted_business_names:
            true_business = search_location_by_name(business_name, locations_db)
            if true_business is not None:
                output_businesses_final.append(true_business)
    
    all_businesses = []
    all_businesses_full = []
    open_businesses = []
    open_businesses_full = []
    
    for business in output_businesses_final[:limit]:
        day_of_week = now.strftime('%A')
        hours_list = business.get('hours', {}).get(day_of_week)

        if is_within_hours(now, hours_list):
            open_businesses.append(business["name"])
            open_businesses_full.append(business)

        all_businesses.append(business["name"])
        all_businesses_full.append(business)

    if cur_open == 1:
        add_message_to_session_id(json.dumps(open_businesses_full), session_id, redis_url, key_prefix="locations")
        return open_businesses
    else:
        add_message_to_session_id(json.dumps(all_businesses_full), session_id, redis_url, key_prefix="locations")
        return all_businesses

def get_location_general_description(business_name: str, locations_db: Collection) -> Optional[LocationInfoCondensed]:
    """Retrieve the general description of a location."""
    business = search_location_by_name(business_name, locations_db)
    
    if business:
        location_info = LocationInfoCondensed(
            name=business["name"],
            address=business["address"],
            stars=business["stars"],
            review_count=business["review_count"],
            cur_open=business["cur_open"],
            price=business["price"],
            phone=business["display_phone"],
            summary=business.get("summary", "No summary available"),
            tags=business["tags"]
        )
        return location_info
    else:
        return None

def get_location_address(business_name: str, locations_db: Collection) -> Optional[LocationInfoFunctionReturn]:
    """Retrieve the address of a location."""
    business = search_location_by_name(business_name, locations_db)
    
    if business:
        location_info = LocationInfoFunctionReturn(
            business_name=business["name"],
            content=business["address"]
        )
        return location_info

    else:
        return None

def get_location_review_summary(business_name: str, locations_db: Collection) -> Optional[LocationInfoFunctionReturn]:
    """Retrieve the summary of a location's reviews."""
    business = search_location_by_name(business_name, locations_db)

    if business:
        location_info = LocationInfoFunctionReturn(
            business_name=business["name"],
            content=business["summary"]
        )
        return location_info
    
    else:
        return None

def get_location_review_count(business_name: str, locations_db: Collection) -> Optional[LocationInfoFunctionReturn]:
    """Retreive the number of reviews of a location."""
    business = search_location_by_name(business_name, locations_db)

    if business:
        location_info = LocationInfoFunctionReturn(
            business_name=business["name"],
            content=str(business["review_count"])
        )
        return location_info
    
    else:
        return None

def get_location_rating_score(business_name: str, locations_db: Collection) -> Optional[LocationInfoFunctionReturn]:
    """Retrieve the star rating of a location (score is between 1 through 5)."""
    business = search_location_by_name(business_name, locations_db)

    if business:
        location_info = LocationInfoFunctionReturn(
            business_name=business["name"],
            content=str(business["stars"])
        )
        return location_info
    
    else:
        return None

def get_location_phone_number(business_name: str, locations_db: Collection) -> Optional[LocationInfoFunctionReturn]:
    """Retrieve the phone number of a location."""
    business = search_location_by_name(business_name, locations_db)

    if business:
        location_info = LocationInfoFunctionReturn(
            business_name=business["name"],
            content=business["phone"]
        )
        return location_info
    
    else:
        return None
    
def initalize_sort_model(model_name: str, api_key: str):

    llm = ChatMistralAI(model=model_name, api_key=api_key)
    parser = CommaSeparatedListOutputParser()

    prompt = ChatPromptTemplate.from_messages([
        ("system", """Given a chat history, a list of locations, and the latest user request \
         which might reference context in the chat history, select and sort the locations from best to worst \
         that best match the user preferences and chat history context. Only return the list of \
         exact names without any additional text."""),
        MessagesPlaceholder("chat_history", optional=True),
        # ("human", "{input}")
        HumanMessagePromptTemplate(
            prompt = PromptTemplate(
                input_variables=["input", "list_of_locations"],
                template= (
                    "\nLatest User Request: {input}\n"
                    "\nList of Locations: {list_of_locations}\n"
                    "\nFormat Instructions: {format_instructions}\n"
                    "Select and sort the locations from best to worst based on the chat history and latest user request to best match the user preferences. Only return the list of exact business names without any additional text."
                ),
                partial_variables={"format_instructions": parser.get_format_instructions()}
            )
        )
    ])

    chain = prompt | llm | parser

    return chain

def initalize_chat_model(model_name: str, api_key: str, redis_url: str, locations_db: Collection, latitude: float, longitude: float, session_id: str, sort_model):
    get_location_recommendations_tool = StructuredTool.from_function(
        func=lambda cur_open=1, sort_by="llmsort", limit=30, radius=10000, tags=["all"]: get_location_recommendations(
            latitude=latitude,
            longitude=longitude,
            tags=tags,
            radius=radius,
            limit=limit,
            cur_open=cur_open,
            sort_by=sort_by,
            locations_db=locations_db,
            session_id=session_id,
            redis_url=redis_url,
            sort_model=sort_model
        ),
        name="get_location_recommendations_tool",
        description="Retrieve location recommendations based on user preferences.",
        args_schema=NearbyLocationInput,
        return_direct=False
    )

    location_general_description_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_general_description(business_name, locations_db),
        name = "location_general_description_tool",
        description = "Retrieve the general description of a location.",
        args_schema = LocationNameInput,
        return_direct = False
    )

    location_address_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_address(business_name, locations_db),
        name = "location_address_tool",
        description = "Retrieve the address of a location.",
        args_schema = LocationNameInput,
        return_direct = False
    )

    location_review_summary_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_review_summary(business_name, locations_db),
        name = "location_review_summary_tool",
        description = "Retrieve the summary of a location's reviews.",
        args_schema = LocationNameInput,
        return_direct = False
    )

    location_review_count_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_review_count(business_name, locations_db),
        name = "location_review_count_tool",
        description = "Retreive the number of reviews of a location.",
        args_schema = LocationNameInput,
        return_direct = False
    )

    location_rating_score_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_rating_score(business_name, locations_db),
        name = "location_rating_score_tool",
        description = "Retrieve the star rating of a location (score is between 1 through 5).",
        args_schema = LocationNameInput,
        return_direct = False
    )

    location_phone_number_tool = StructuredTool.from_function(
        func = lambda business_name: get_location_phone_number(business_name, locations_db),
        name = "location_phone_number_tool",
        description = "Retrieve the phone number of a location.",
        args_schema = LocationNameInput,
        return_direct = False
    )

    tools = [get_location_recommendations_tool,
             location_general_description_tool, 
             location_address_tool, 
             location_review_summary_tool, 
             location_review_count_tool, 
             location_rating_score_tool,
             location_phone_number_tool]

    llm = ChatMistralAI(model=model_name, api_key=api_key)

    instructions = (
        "As a location recommender for the WhatNext? app, your primary role is to provide personalized recommendations for places to visit, dine, or activities to enjoy based on user preferences using your avaliable functions. Respond in a friendly and concise manner like a real person. The responses must be short and concise to mimic standard text messages.\n\n"
        "All recommendation queries/requests MUST trigger the get_location_recommendations_tool function. Do not suggest locations without using this function.\n"
        "To assist users effectively, adhere to the following protocol:\n\n"
        "1. Identify Requests for Suggestions: Scan user messages for keywords such as 'looking for', 'suggest', or any mention of specific places or activities.\n"
        "2. Whenever the user asks for recommendations, ALWAYS use the get_location_recommendations_tool BEFORE you respond to the user.\n"
        "3. If get_location_recommendations_tool yields no results, inform the user that there are no open, nearby, or relevant locations matching their criteria.\n"
        "4. Handle Specific Location Inquiries: If a user asks about a particular location by name, use the necessary location tool to extract the corresponding location detailed information.\n"
        "5. Incorporate User Feedback: Actively incorporate feedback from users. Specifically, when feedback indicates a desire for better or alternative locations, always use get_location_recommendations_tool with the updated criteria to refine the recommendations.\n"
        "6. DO NOT explain the tools or the process being used. Keep responses simple and concise. The responses must be 1-2 sentences maximum.\n"
    )

    prompt = ChatPromptTemplate.from_messages(
        [
            (
                "system",
                instructions,
            ),
            MessagesPlaceholder(variable_name="chat_history", optional=True),
            HumanMessagePromptTemplate(
                prompt = PromptTemplate(input_variables=["input"], template="{input}")
            ),
            MessagesPlaceholder(variable_name="agent_scratchpad"),
        ]
    )

    agent = create_tool_calling_agent(llm, tools, prompt)

    agent_executor = AgentExecutor.from_agent_and_tools(
        agent=agent, 
        tools=tools,
        early_stopping_method="force",
        verbose=False,
        max_execution_time=15)
    
    agent_with_message_history = RunnableWithMessageHistory(
        agent_executor,
        get_session_history = lambda session_id: get_session_history(session_id, redis_url),
        input_messages_key="input",
        history_messages_key="chat_history"
    )
    
    return agent_with_message_history
