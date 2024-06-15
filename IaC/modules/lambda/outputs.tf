output "create_short_url_lambda_arn" {
  value = aws_lambda_function.create_short_url.arn
}

output "redirect_url_lambda_arn" {
  value = aws_lambda_function.redirect_url.arn
}