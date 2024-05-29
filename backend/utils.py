from datetime import timedelta
import uuid
import json

# Checks if the businesses is currently open
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

# Generate new session id
def generate_unique_session_id():
    return str(uuid.uuid4())

# Generate new thread id
def generate_thread_id(openai_client):
    thread = openai_client.beta.threads.create()
    return thread.id

def open_json_file(file_path):
    with open(file_path, 'r') as file:
        file_content = json.load(file)
    return file_content

# Generate new assistant id
def generate_assistant_id(openai_client):
    valid_limit = ["5", "10", "15"]
    valid_radius = ["500", "1600", "5000", "10000", "20000"]
    valid_cur_open = [0, 1, 1]
    categories_file_path = "categories.json"
    tags_file_path = "tags.json"
    valid_categories = open_json_file(categories_file_path)
    valid_tags = open_json_file(tags_file_path)
    valid_sort_by = ["review_count", "stars", "random"]
    tools = [
        {
            "type": "function",
            "function": {
                "name": "fetch_nearby_locations_condensed",
                "description": "Retrieve the locations of potential places for users to visit (DO NOT NEED USERS LOCATION)",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "limit": {
                            "type": "string",
                            "enum": valid_limit,
                            "description": f"Specifies the number of locations to retrieve. Default: 5."
                        },
                        "radius": {
                            "type": "string",
                            "enum": valid_radius,
                            "description": f"Defines the search radius in meters. 500 meter is walkable, 1600 is close, 5000 is close/medium, 10000 is medium, and 20000 is far distance. Default: 10000."
                        },
                        "categories": {
                            "type": "string",
                            "enum": valid_categories,
                            "description": f"Primary categories to filter the search, representing broad sectors or types of locations. You can have a list of categories in string format. Categories help in segmenting locations into major groups for easier discovery. Categories must be in 'enum'. Example: 'shopping'."
                        },
                        "cur_open": {
                            "type": "string",
                            "enum": [0, 1],
                            "description": f"Filter based on current open status. 0 for both closed and open, while 1 is just for open. Use 0 when seeking recommendations for future dates. Default: {valid_cur_open[2]}."
                        },
                        "tag": {
                            "type": "string",
                            "enum": valid_tags,
                            "description": f"Optional tags to refine your search based on specific attributes or specialties within a category. You can have a list of tags. Tags provide a granular level of filtering to help you find locations that offer particular services, cuisines, or features. Tags must be in 'enum'."
                        },
                        "sort_by": {
                            "type": "string",
                            "enum": valid_sort_by,
                            "description": f"Sorts the results by the specified criteria. Options: {', '.join(valid_sort_by[:-1])}, or {valid_sort_by[-1]}."
                        }
                    },
                    "required": ["categories", "tag"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "fetch_specific_location",
                "description": "Input a business_id and retrieve its detailed information (ONLY FOR SPECIFIC BUSINESS_ID QUERY).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "business_id": {
                            "type": "string",
                            "description": f"The business_id used to identify a specifc location. The business_id is composed of the category and a four-digit number."
                        }
                    },
                    "required": ["business_id"],
                }
            }
        }
    ]
    instructions = (
        "As a location recommender for the WhatNext? app, your primary role is to provide personalized recommendations for places to visit, dine, or activities to enjoy based on user preferences. Respond in a friendly and funny manner like a real person. The responds must be short and concise to mimic standard text messages."
        "Do not act for user's location. To assist users effectively, adhere to the following protocol:\n\n"
        "Identify Requests for Suggestions: Scan user messages for keywords such as 'looking for', 'suggest', or any mention of specific places or activities. This step is critical for recognizing when a user is seeking recommendations. If you can not infer tag from the conversation, ask for clarity but also consider tag from last message."
        "Engage for Specificity: Directly engage with users to narrow down broad or vague prompts into more detailed requests. This direct interaction helps tailor recommendations to their specific preferences without asking for their location. If you think the user question is vague, confirm with the user. When user ask for more options such as 'more','more options','give me more' or anything you think the user wants more or others recommendations, you must always confirm with the user for clarity, you should never re-trigger fetch_nearby_locations_condensed before you confirm with the user for clarity"
        "Analyze User Preferences: Deduce user preferences from the conversation. Use this analysis to trigger fetch_nearby_locations_condensed for finding suitable recommendations. If fetch_nearby_locations_condensed yields no results, inform the user that there are not open, nearby, and ask if they want to check something else."
        "Handle Specific Location Inquiries: If a user asks about a particular location by name, extract the corresponding business_id and trigger fetch_specific_location to provide detailed information about that location."
        "Incorporate User Feedback: Actively incorporate feedback from users. Specifically, when feedback indicates a desire for better or alternative locations, always re-trigger fetch_nearby_locations_condensed with the updated criteria to refine the recommendations. Do not give the same recommendations for same places as prior messages."
        "No Duplication: Always remeber the recommendations that are given so far, and always go back to the previous conversation to make sure you do not give the same recommendations as prior unless the user wants duplication."
    )
    assistant = openai_client.beta.assistants.create(
        instructions=instructions,
        name="WhatNext? Location Recommender",
        #model="gpt-3.5-turbo-0125",
        model="gpt-4o",
        tools=tools,
        temperature=1
    )
    return assistant.id

# Create sorting run
def create_sorting_run(openai_client, thread_id, assistant_id):
    instructions = (
        "As the WhatNext? app's location sorter, review the user's most recent request, the prior conversation history, and user bio for details on user preference. "
        "Only use the user bio or preferences for sorting. "
        "Identify and rank, from highest to lowest ranked, the locations that best match the user's preference. "
        "Your response should be a comma-separated list of business_id associated with these locations, "
        "with a single space after each comma, and no spaces before the IDs or additional characters. "
        "The format must be exactly as follows: 'business_id1, business_id2, business_id3, ...'. "
        "Ensure the output adheres strictly to this structure, without any prefixes, bullet points, explanation, and additional text."
    )
    
    run_sort = openai_client.beta.threads.runs.create(
        thread_id=thread_id,
        assistant_id=assistant_id,
        instructions=instructions,
        tools=[],
        # model="gpt-3.5-turbo-0125",
        # model="gpt-4-0125-preview"
        model="gpt-4o"
    )
    return run_sort.id

# Retrieves thread_id and assistant_id based on session_id
def retrieve_chat_info(session_id, redis_client, openai_client, assistant_id):
    if session_id is None or not redis_client.exists(session_id):
        session_id = generate_unique_session_id()
        thread_id = generate_thread_id(openai_client)
        redis_client.hset(session_id, mapping={"thread_id": thread_id, "assistant_id": assistant_id})
    values = redis_client.hgetall(session_id)
    thread_id = values.get(b"thread_id").decode("utf-8") if values.get(b"thread_id") else None
    assistant_id = values.get(b"assistant_id").decode("utf-8") if values.get(b"assistant_id") else None
    return session_id, thread_id

# Retrieves user preference
def retrieve_user_preference(user_id, redis_client):
    user_preference = redis_client.lrange(user_id, 0, -1)
    return user_preference

# Updates user preference
def update_user_preference(user_id, new_preferences, redis_client):
    key_type = redis_client.type(user_id)
    current_preferences = set()
    if key_type == b'list':
        current_preferences = set(redis_client.lrange(user_id, 0, -1).decode('utf-8'))
    elif key_type != b'none':
        redis_client.delete(user_id)

    # remove any duplicates
    new_preferences_set = set(new_preferences)
    updated_preferences = current_preferences.union(new_preferences_set)
    if updated_preferences:
        updated_preferences = [pref.decode('utf-8') if isinstance(pref, bytes) else pref for pref in updated_preferences]
        redis_client.delete(user_id)
        redis_client.rpush(user_id, *updated_preferences)
    
    return updated_preferences