# -----------------------------------------
# Module: AWS_LAMBDA output
# -----------------------------------------

output "lambda_arn" {
  value = aws_lambda_function._.arn
}

output "invoke_url" {
  value = aws_lambda_function._.invoke_arn
}

output "lambda_invoke_arn" {
  value = aws_lambda_function._.invoke_arn
}
