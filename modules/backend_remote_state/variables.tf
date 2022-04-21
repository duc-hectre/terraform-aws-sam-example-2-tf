# ---------------------------------------------------
# Define variables of Terraform backend remote state
# ---------------------------------------------------

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

variable "terraform_user" {
  type        = string
  description = "User account for Terraform Backend remote state"
}

variable "bucket_terraform_state_base_name" {
  type        = string
  description = "Bucket name for saving Terraform state file"
}

variable "table_terraform_lock_base_name" {
  type        = string
  description = "Dynamo DB table name for Terraform remote backend session lock management"
}
