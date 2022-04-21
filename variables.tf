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

variable "tf_codestar_connector_credentials" {
  description = "Connection to github repository"
  type        = string
}

variable "tf_branch_name" {
  description = "git branch for terraform part"
  type        = string
}


variable "tf_repository" {
  description = "git branch for terraform part"
  type        = string
}

variable "sam_repository" {
  description = "git branch for terraform part"
  type        = string
}

variable "sam_codestar_connector_credentials" {
  description = "Connection to github repository"
  type        = string
}


variable "sam_branch_name" {
  description = "git branch for sam part"
  type        = string
}

variable "bucket_terraform_state_base_name" {
  type        = string
}
variable "table_terraform_lock_base_name" {
  type        = string
}

variable "terraform_user" {
  type        = string
}

