<!-- ```markdown -->
# Serverless URL Shortener Application

This project demonstrates how to build a serverless URL shortener application using AWS services like AWS Lambda, API Gateway, DynamoDB, and optionally S3 for hosting a static frontend.

![image](https://github.com/LithiraAponsu2/aws-serverless-url-shortner/assets/95391677/0d1f1769-228c-4b6b-848c-3ab90a43c87f)

![image](https://github.com/LithiraAponsu2/aws-serverless-url-shortner/assets/95391677/a8d8f111-1061-4d5b-b35a-4ff7287bfe63)

## Prerequisites

- AWS account
- AWS CLI installed and configured
- Python 3.x and pip installed

## Project Setup

### 1. Create a DynamoDB Table

1. Go to the DynamoDB console in the AWS Management Console.
2. Click on "Create table".
3. Enter "URLs" as the table name.
4. Set the partition key as "short_url" (String).
5. Leave the default settings for the rest of the options and click "Create".

### 2. Create an IAM Role for Lambda

1. Go to the IAM console in the AWS Management Console.
2. Click on "Roles" and then "Create role".
3. Select "AWS service" as the trusted entity and "Lambda" as the use case.
4. Click "Next: Permissions".
5. Attach the "AWSLambdaBasicExecutionRole" policy and the "AmazonDynamoDBFullAccess" policy.
6. Click "Next: Tags" and then "Next: Review".
7. Enter a role name like "LambdaURLShortenerRole" and click "Create role".

### 3. Create Lambda Functions

#### 3.1 Create the "CreateShortURL" Lambda Function

1. Go to the Lambda console in the AWS Management Console.
2. Click "Create function".
3. Select "Author from scratch".
4. Enter a function name like "CreateShortURL".
5. Select the Python 3.x runtime.
6. Under "Permissions", expand "Change default execution role" and select the "Use an existing role" option.
7. Select the "LambdaURLShortenerRole" role you created earlier.
8. Click "Create function".
9. Copy the contents of the `create_short_url.py` file (provided later) into the code editor.
10. Click "Deploy".

#### 3.2 Create the "RedirectURL" Lambda Function

1. Go to the Lambda console in the AWS Management Console.
2. Click "Create function".
3. Select "Author from scratch".
4. Enter a function name like "RedirectURL".
5. Select the Python 3.x runtime.
6. Under "Permissions", expand "Change default execution role" and select the "Use an existing role" option.
7. Select the "LambdaURLShortenerRole" role you created earlier.
8. Click "Create function".
9. Copy the contents of the `redirect_url.py` file (provided later) into the code editor.
10. Click "Deploy".

### 4. Create an API Gateway HTTP API

1. Go to the API Gateway console in the AWS Management Console.
2. Click "Create API".
3. Select "HTTP API" and click "Next".
4. Enter an API name like "URLShortenerAPI".
5. Select "Private" for the API protocol and click "Next".
6. Review the settings and click "Create".
7. In the left-hand navigation, click "Integrations".
8. Click "Create" and select "Lambda function" as the integration target.
9. Enter "CreateShortURL" as the Lambda function name and click "Create".
10. Click on the "CreateShortURL" integration and click "Add mapping".
11. Enter "POST /shorten" as the HTTP method and resource path, and click "Save".
12. In the left-hand navigation, click "Routes".
13. Click "Create" and select "Lambda function" as the integration target.
14. Enter "RedirectURL" as the Lambda function name and click "Create".
15. Click on the "RedirectURL" integration and click "Add mapping".
16. Enter "GET /{short_url}" as the HTTP method and resource path, and click "Save".
17. Note down the API Gateway Invoke URL (e.g., <https://abc123.execute-api.us-east-1.amazonaws.com/>).

### 5. (Optional) Host a Static Frontend

If you want to host a static frontend for interacting with the URL shortener, you can use S3 and create a new bucket.

1. Go to the S3 console in the AWS Management Console.
2. Click "Create bucket".
3. Enter a bucket name and select the desired region.
4. Click "Create bucket".
5. Upload your HTML, CSS, and JavaScript files to the bucket.
6. Configure the bucket for static website hosting.
7. Note down the website endpoint URL (e.g., <http://example-bucket.s3-website-us-east-1.amazonaws.com>).

### 6. Test the Application

You can now test the URL shortener application using the API Gateway Invoke URL and the provided Python files.

#### create_short_url.py

```python
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
```

#### redirect_url.py

```python
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
```

To create a short URL:

1. Send a POST request to the API Gateway Invoke URL with the path `/shorten` and the long URL in the request body.
2. The response will contain the short URL.

To access the original URL from the short URL:

1. Send a GET request to the API Gateway Invoke URL with the path `/{short_url}`, replacing `{short_url}` with the short URL you received earlier.
2. You will be redirected to the original long URL.

If you hosted a static frontend, you can access it through the website endpoint URL and interact with the URL shortener application.

## Cleanup

To avoid incurring unnecessary charges, remember to delete the resources you created during this project, including the Lambda functions, API Gateway, DynamoDB table, and S3 bucket.

```

This README file provides detailed instructions on how to set up the serverless URL shortener application using AWS services like AWS Lambda, API Gateway, DynamoDB, and S3 (optional). It covers the steps to create the required resources, configure the Lambda functions, and test the application. Additionally, it includes cleanup instructions to delete the resources and avoid unnecessary charges.

Warning: Names of some files are different, please be aware of that, and take this as a challenge and try to correct them.
Also, the "console" folder content may help deploy and test your application when you create using AWS Console.
