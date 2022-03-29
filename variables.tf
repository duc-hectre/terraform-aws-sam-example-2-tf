# -----------------------------------------------------------------------------
# Variables: General
# -----------------------------------------------------------------------------

variable "environment" {
  description = "AWS resource environment/prefix"
  default     = "dev"
}

variable "region" {
  description = "AWS region"
  default     = "ap-southeast-1"
}

variable "resource_tag_name" {
  description = "Resource tag name for cost tracking"
  default     = "todo-a2"
}

variable "codestar_connector_credentials" {
  description = "Connection to github repository"
  type        = string
}
