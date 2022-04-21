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
# Variables: CICD
# -----------------------------------------------------------------------------

variable "codestar_connector_credentials" {
  description = "codestar_connector_credentials"
}

variable "pipeline_artifact_bucket" {
  description = "pipeline_artifact_bucket name"
}

variable "github_repository_id" {
  description = "Full id of gitgub repo"
}

variable "github_branch" {
  description = "github branch to pull the source code"
}

variable "pipeline_name" {
  description = "Code pipeline name for terraform part"
}