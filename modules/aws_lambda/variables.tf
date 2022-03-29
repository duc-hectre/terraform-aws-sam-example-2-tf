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

variable "invoke_by_event" {
  type        = bool
  description = "indicate whether lambda is invoked by api gateway or other events"
  default     = false
}


# -----------------------------------------------------------------------------
# Variables: Lambda
# -----------------------------------------------------------------------------

variable "function_name" {
  description = "AWS resource environment/prefix"
}

variable "file_name" {
  description = "file name reference"
}

variable "handler_name" {
  description = "handler function name to be invoked in lambda"
}
variable "role_arn" {
  description = "Role permission of lambda function"
}
variable "source_arn" {
  description = "api gateway source which has granted permission to invoke lambda"
}
variable "lambda_variables" {
  type        = map(string)
  description = "object to define all the lambda environment variables"
  default = {

  }
}
