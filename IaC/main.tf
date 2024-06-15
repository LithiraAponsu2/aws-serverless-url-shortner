provider "aws" { 
  region = var.region
}

module "dynamodb" {
  source = "./modules/dynamodb"
}

module "iam" {
  source = "./modules/iam"
}

module "lambda" {
  source      = "./modules/lambda"
  lambda_role_arn = module.iam.lambda_role_arn
  urls_table  = module.dynamodb.dynamodb_table_name
}

module "api_gateway" {
  source                  = "./modules/api-gateway"
  create_short_url_lambda = module.lambda.create_short_url_lambda_arn
  redirect_url_lambda     = module.lambda.redirect_url_lambda_arn
}

module "s3_website" {
  source = "./modules/s3-bucket"
  api_id = module.api_gateway.api.id
  region = var.region
}



