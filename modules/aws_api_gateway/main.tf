
locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}


# -----------------------------------------------------------------------------
# Resource: API Gateway
# -----------------------------------------------------------------------------


resource "aws_api_gateway_rest_api" "_" {
  name        = "${local.resource_name_prefix}-${var.api_name}"
  description = "Terraform serverless demo api gateway"
}

resource "aws_api_gateway_resource" "_" {
  rest_api_id = aws_api_gateway_rest_api._.id
  parent_id   = aws_api_gateway_rest_api._.root_resource_id
  path_part   = var.resource_path
}

resource "aws_api_gateway_method" "_" {
  resource_id   = aws_api_gateway_resource._.id
  rest_api_id   = aws_api_gateway_rest_api._.id
  http_method   = var.http_method
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "_" {
  rest_api_id = aws_api_gateway_rest_api._.id
  resource_id = aws_api_gateway_method._.resource_id
  http_method = aws_api_gateway_method._.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_uri
}

# resource "aws_api_gateway_method" "__root" {
#   rest_api_id   = aws_api_gateway_rest_api._.id
#   resource_id   = aws_api_gateway_rest_api._.root_resource_id
#   http_method   = "ANY"
#   authorization = "NONE"
# }


# resource "aws_api_gateway_integration" "lambda_root" {
#   rest_api_id = aws_api_gateway_rest_api._.id
#   resource_id = aws_api_gateway_rest_api._.root_resource_id
#   http_method = aws_api_gateway_method.__root.http_method

#   integration_http_method = "POST"
#   type                    = "AWS_PROXY"
#   uri                     = aws_lambda_function.tf_demo_function.invoke_arn
# }

resource "aws_api_gateway_deployment" "_" {
  depends_on = [
    aws_api_gateway_integration._
  ]
  rest_api_id = aws_api_gateway_rest_api._.id
  stage_name  = var.deployment_state
}
