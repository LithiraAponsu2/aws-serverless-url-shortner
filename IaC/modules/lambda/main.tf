# add short url creating python code as zip
data "archive_file" "create_short_url_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda_functions/create_short_url/"  # ../../ - moves up twise directories
  output_path = "${path.module}/create_short_url.zip"
}


# create short url function
resource "aws_lambda_function" "create_short_url" {
  filename         = data.archive_file.create_short_url_zip.output_path
  function_name    = "CreateShortURL"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"  # python code function of handler
  runtime          = "python3.12" 
  # source_code_hash = data.archive_file.create_short_url_zip.output_base64sha256  # trigger updates to the Lambda function when the source code changes, dont need if dont think to change code

  environment {
    variables = {
      URLS_TABLE = var.urls_table  # dynamo db table needed for the python code
    }
  }
}

# add redirecting python code as zip
data "archive_file" "redirect_url_zip" {
  type        = "zip"
  source_dir  = "${path.module}/../../lambda_functions/redirect_url/"
  output_path = "${path.module}/redirect_url.zip"
}


# redirect to original url function
resource "aws_lambda_function" "redirect_url" {
  filename         = data.archive_file.redirect_url_zip.output_path
  function_name    = "RedirectURL"
  role             = var.lambda_role_arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.9"
  # source_code_hash = data.archive_file.redirect_url_zip.output_base64sha256

  environment {
    variables = {
      URLS_TABLE = var.urls_table
    }
  }
}