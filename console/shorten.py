import json
import string
import random
import boto3

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = 'URLs'  # Replace with your DynamoDB table name
table = dynamodb.Table(table_name)

def generate_short_url():
    characters = string.ascii_letters + string.digits
    short_url = ''.join(random.choice(characters) for _ in range(6))
    return short_url

def lambda_handler(event, context):
    try:
        # Parse the JSON body from the event
        if 'body' in event:
            body = json.loads(event['body'])
        else:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Request body is missing"}),
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                }
            }
        
        long_url = body.get('longURL')

        # Validate if long_url is present
        if not long_url:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'longURL' in request body"}),
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                }
            }

        # Generate a short URL key
        short_key = generate_short_url()

        # Check if the generated short URL already exists
        response = table.get_item(
            Key={
                'shortURL': short_key
            }
        )
        if 'Item' in response:
            # If it exists, generate a new one
            short_key = generate_short_url()

        # Construct the DynamoDB item to be inserted
        item = {
            'shortURL': short_key,
            'longURL': long_url
        }

        # Store the mapping in DynamoDB
        table.put_item(Item=item)

        # Construct the response
        response = {
            "statusCode": 200,
            "body": json.dumps({"shortURL": f"https://qi65jb566f.execute-api.us-east-1.amazonaws.com/{short_key}"}),
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        }

        return response
    
    except Exception as e:
        error_message = f"Unexpected error: {str(e)}"
        print(error_message)
        return {
            "statusCode": 500,
            "body": json.dumps({"error": error_message}),
            "headers": {
                "Content-Type": "application/json",
                "Access-Control-Allow-Origin": "*"
            }
        }
