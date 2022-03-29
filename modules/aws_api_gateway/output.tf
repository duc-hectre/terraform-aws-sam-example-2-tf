# -----------------------------------------
# Module: AWS_LAMBDA output
# -----------------------------------------

output "api_arn" {
  value = aws_api_gateway_rest_api._.arn
}

output "api_execution_arn" {
  value = aws_api_gateway_rest_api._.execution_arn
}
