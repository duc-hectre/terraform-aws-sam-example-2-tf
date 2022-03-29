
locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}


# -----------------------------------------------------------------------------
# Variables: Lambda function run on Python 3.8
# -----------------------------------------------------------------------------

resource "aws_lambda_function" "_" {
  function_name    = "${local.resource_name_prefix}-${var.function_name}"
  filename         = var.file_name
  source_code_hash = filebase64sha256(var.file_name)
  handler          = var.handler_name
  runtime          = "python3.8"
  role             = var.role_arn

  environment {
    variables = var.lambda_variables
  }
}

resource "aws_lambda_permission" "_" {
  count         = var.invoke_by_event ? 0 : 1
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function._.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = var.source_arn
}

resource "aws_lambda_event_source_mapping" "_" {
  count            = var.invoke_by_event ? 1 : 0
  event_source_arn = var.source_arn
  function_name    = aws_lambda_function._.function_name
}
