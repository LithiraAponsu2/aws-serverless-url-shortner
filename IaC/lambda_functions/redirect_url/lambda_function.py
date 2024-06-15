import json
import boto3
import os

dynamodb = boto3.resource('dynamodb')
table = dynamodb.Table(os.environ['URLS_TABLE'])

def lambda_handler(event, context):
    try:
        short_url = event['pathParameters']['short_url']
        
        response = table.get_item(Key={'short_url': short_url})
        
        if 'Item' in response:
            long_url = response['Item']['long_url']
            return {
                "statusCode": 301,
                "headers": {
                    "Location": long_url
                }
            }
        else:
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "URL not found"}),
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"
                }
            }
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