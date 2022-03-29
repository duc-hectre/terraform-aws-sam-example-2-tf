# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "environment" {
  description = "AWS resource environment/prefix"
}

variable "region" {
  description = "AWS region"
}

variable "resource_tag_name" {
  description = "Resource tag name for cost tracking"
}

# -----------------------------------------------------------------------------
# Variables: Lambda
# -----------------------------------------------------------------------------

variable "api_name" {
  description = "AWS resource name"
}

variable "resource_path" {
  description = "API resource name/path, ex: hello, {proxy+} for proxy"
}

variable "http_method" {
  description = "API http method, ex: GET, POST, OPTIONS, PUT, PATCH, ANY"
}
variable "lambda_uri" {
  description = "Lambda uri to invoke"
}
variable "deployment_state" {
  description = "deployment state for the api gateway"
}
