import json
import string
import random
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['URLS_TABLE'])

def generate_short_url():
    characters = string.ascii_letters + string.digits
    short_url = ''.join(random.choice(characters) for _ in range(6))
    return short_url

def lambda_handler(event, context):
    try:
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
        
        long_url = body.get('long_url')

        if not long_url:
            return {
                "statusCode": 400,
                "body": json.dumps({"error": "Missing 'long_url' in request body"}),
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                }
            }

        short_key = generate_short_url()

        response = table.get_item(
            Key={
                'short_url': short_key
            }
        )
        while 'Item' in response:
            short_key = generate_short_url()
            response = table.get_item(
                Key={
                    'short_url': short_key
                }
            )

        item = {
            'short_url': short_key,
            'long_url': long_url
        }

        table.put_item(Item=item)

        response = {
            "statusCode": 200,
            "body": json.dumps({"short_url": f"https://{event['headers']['Host']}/{short_key}"}),
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