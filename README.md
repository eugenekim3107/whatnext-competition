# Project Poster

![WhatNext Project Poster](assets/whatnext-poster.png)

# AWS Cloud Server Setup/Login

## AWS Console Login
  1. Log in to AWS console using registered account: https://d-9267bea535.awsapps.com/start
  2. Type in the command line aws configure sso
  3. Provide necessary info (client region, output format, profile name)
  4. Based on your given profile name (step 3), type in the command line aws s3 ls --profile eugenekim3107 (assuming profile name is "eugenekim3107")
  5. Copy and paste the AWS environment variables

## Local Development and Testing
To develop and test locally while connecting to MongoDB hosted on the EC2 instance, follow these steps:

### MongoDB SSH Port Forwarding

Set up SSH port forwarding to connect to MongoDB on the EC2 instance:
1. Secure the SSH key:
```
chmod 400 whatnext/backend/WhatNextAdminKey.pem
```
2. Establish an SSH tunnel for MongoDB access:
```
ssh -i whatnext/backend/WhatNextAdminKey.pem -L 8000:localhost:27017 ubuntu@<Elastic-IP>
```
- `8000`: Local port on your machine for MongoDB.
- `localhost:27017`: Remote destination (MongoDB port on EC2 instance).
- `Elastic-IP`: Replace with the actual Elastic IP address of your EC2 instance.
3. Login to MongoDB (within EC2):
```
mongosh -u eugenekim -p whatnext -authenticationDatabase admin
```

### Redis-server SSH Port Forwarding

Set up SSH port forwarding to connect to Redis-server on the EC2 instance:
1. Secure the SSH key:
```
chmod 400 whatnext/backend/WhatNextAdminKey.pem
```
2. Establish an SSH tunnel for Redis-server access:
```
ssh -i whatnext/backend/WhatNextAdminKey.pem -L 8001:localhost:6379 ubuntu@<Elastic-IP>
```
- `8001`: Local port on your machine for Redis-server.
- `localhost:6379`: Remote destination (Redis-server port on EC2 instance).
- `Elastic-IP`: Replace with the actual Elastic IP address of your EC2 instance.

### Running FastAPI Server
To start the FastAPI server locally:
```
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```
- `0.0.0.0`: Binds the server to all IP addresses.
- `8080`: Specifies the port for the FastAPI server.
- `--reload`: Enables auto-reload on file changes for development.
- Ensure the packages in requirements.txt are correctly installed in your environment.

### Testing Endpoints
To test an endpoint, use the following command:
```
curl -X 'GET' 'http://localhost:8080/nearby_locations'
```

```
curl -X POST "http://localhost:8080/chatgpt_response" -H "Content-Type: application/json" -d '{"user_id": "wiVOrMOJ8COqs7d6OgCBNVTV9lt2", "message": "I would like to drink some coffee", "latitude": 32.8723812680163, "longitude": -117.21242234341588}'
```

To continue a conversation, input the session_id into the POST:
```
curl -X POST "http://localhost:8080/chatgpt_response" -H "Content-Type: application/json" -d '{"user_id": "wiVOrMOJ8COqs7d6OgCBNVTV9lt2", "session_id": <session-id>, "message": "Thank you for the information!", "latitude": 32.8723812680163, "longitude": -117.21242234341588}'
```

## Production
For setting up your environment for production, follow these steps:

### SSH Port Forwarding
Repeat the steps for SSH port forwarding as in the local development and testing section to connect to MongoDB on the EC2 instance.

### Running Docker Container and Databases
Ensure MongoDB is running on the EC2 instance. It should run automatically upon initialization. To check the status of MongoDB:
```
systemctl status mongod
```
If MongoDB is not running, initialize the database using:
```
sudo systemctl start mongod
sudo systemctl enable mongod
```

Ensure Redis-server is running on the EC2 instance. It should run automatically upon initalization. To check the status of the Redis-server:
```
systemctl status redis-server.service
```
If Redis-server is not running, initalize the database using:
```
sudo systemctl start redis-server.service
sudo systemctl enable redis-server.service
```

Ensure the Docker container is running on the EC2 instance. It should run automatically upon initialization. To check the status of the Docker container:
```
docker ps
```
If the Docker conatiner is not running, initialize the database using:
```
docker run -d --restart=always --name whatnext-container -p 8000:8000 --env OPENAI_API_KEY=$OPENAI_API_KEY
```
- `whatnext-container`: The name of the container.
- `whatnext-image`: The name of the image.

### Testing Endpoints
To test an endpoint in production, use the following command:
```
curl -k "https://api.whatnext.live/nearby_locations"
```
```
curl -k -X POST "https://api.whatnext.live/chatgpt_response" -H "Content-Type: application/json" -d '{"user_id": "wiVOrMOJ8COqs7d6OgCBNVTV9lt2", "message": "I want to go hiking. Can you give me some suggestions?", "latitude": 32.8723812680163, "longitude": -117.21242234341588}'
```

## Important Notes

**Official Website**: [whatnext.live](https://whatnext.live)

### API Usage Guidelines

To ensure clarity and maintain a structured approach to API interactions, all API endpoints adhere to a specific path convention:

**Endpoint Prefix**: All API endpoints begin with `api.whatnext.live`.
Examples of API Endpoint Structures:
- **GET Requests**: To retrieve data from our platform, you'll use the GET method with endpoints structured as follows:
```
curl -k "https://api.whatnext.live/[endpoint-name]"
```
- **POST Requests**: For submitting data to our platform, POST requests follow a similar structure:
```
curl -k -X POST "https://api.whatnext.live/[endpoint-name]" -H "Content-Type: application/json" -d '{[field-content]}'
```
By adhering to these guidelines, we ensure that API requests are efficiently processed to the back-end services, facilitating a reliable platform for all users.