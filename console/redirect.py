import json
import boto3

# Initialize DynamoDB client
dynamodb = boto3.resource('dynamodb')
table_name = 'URLShortener'  # Replace with your DynamoDB table name
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    try:
        # Extract the short URL key from the path parameters
        short_url = event['pathParameters']['shortURL']
        
        # Fetch the original URL from DynamoDB
        response = table.get_item(Key={'shortURL': short_url})
        
        if 'Item' in response:
            long_url = response['Item']['longURL']
            
            # Return a 301 redirect response
            return {
                "statusCode": 301,
                "headers": {
                    "Location": long_url
                }
            }
        else:
            # Return a 404 response if the short URL is not found
            return {
                "statusCode": 404,
                "body": json.dumps({"error": "URL not found"}),
                "headers": {
                    "Content-Type": "application/json",
                    "Access-Control-Allow-Origin": "*"  # Adjust CORS as needed
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
                "Access-Control-Allow-Origin": "*"  # Adjust CORS as needed
            }
        }
