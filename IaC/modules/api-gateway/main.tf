resource "aws_apigatewayv2_api" "url_shortener_api" {
  name          = "URLShortenerAPI"
  protocol_type = "HTTP"  # used http instead of http, rest api ran into error when trying to do redirect 301
}

resource "aws_apigatewayv2_integration" "create_short_url_integration" {
  api_id             = aws_apigatewayv2_api.url_shortener_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "POST"
  integration_uri    = var.create_short_url_lambda
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "create_short_url_route" {
  api_id    = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "POST /shorten"
  target    = "integrations/${aws_apigatewayv2_integration.create_short_url_integration.id}"
}

resource "aws_apigatewayv2_integration" "redirect_url_integration" {
  api_id             = aws_apigatewayv2_api.url_shortener_api.id
  integration_type   = "AWS_PROXY"
  integration_method = "GET"
  integration_uri    = var.redirect_url_lambda
  payload_format_version = "2.0"
  
}

resource "aws_apigatewayv2_route" "redirect_url_route" {
  api_id    = aws_apigatewayv2_api.url_shortener_api.id
  route_key = "GET /{short_url}"
  target    = "integrations/${aws_apigatewayv2_integration.redirect_url_integration.id}"
}

resource "aws_apigatewayv2_stage" "url_shortener_stage" {
  api_id      = aws_apigatewayv2_api.url_shortener_api.id
  name        = "Production"
  auto_deploy = true
}