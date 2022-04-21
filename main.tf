locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws",
      version = "~> 3.27"
    }
  }
  backend "s3" {    
  }
}

provider "aws" {
  profile = "srvadm"
  region  = "ap-southeast-1"
}


module "backend_remote_state" {
  source                           = "./modules/backend_remote_state"
  environment                      = var.environment
  region                           = var.region
  resource_tag_name                = var.resource_tag_name
  terraform_user                   = var.terraform_user
  bucket_terraform_state_base_name = var.bucket_terraform_state_base_name
  table_terraform_lock_base_name   = var.table_terraform_lock_base_name
}


#dynamodb

resource "aws_dynamodb_table" "_" {
  name           = "${local.resource_name_prefix}_todo_table"
  hash_key       = "id"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "id"
    type = "S"
  }
}

resource "aws_sqs_queue" "_" {
  name                      = "${local.resource_name_prefix}_queue"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = var.environment
  }
}

module "aws_ssm_params" {
  source = "./modules/aws_ssm"

  app_name    = var.resource_tag_name
  environment = var.environment

  parameters = {
    "dynamodb_name" = {
      "type" : "String",
      "value" : aws_dynamodb_table._.name
    },
    "dynamodb_arn" = {
      "type" : "String",
      "value" : aws_dynamodb_table._.arn
    },
    "sqs_queue_name" = {
      "type" : "String",
      "value" : aws_sqs_queue._.name
    },
    "sqs_queue_arn" = {
      "type" : "String",
      "value" : aws_sqs_queue._.arn
    },
  }
}

module "aws_tf_cicd_pipeline" {
  source = "./modules/aws_tf_cicd_pipeline"

  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  github_repository_id = var.tf_repository
  github_branch        = var.tf_branch_name
  pipeline_name        = "tf-cicd"

  codestar_connector_credentials = var.tf_codestar_connector_credentials
  pipeline_artifact_bucket       = "artifact-bucket"
}

module "aws_sam_dev_cicd_pipeline" {
  source = "./modules/aws_sam_cicd_pipeline"

  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  github_repository_id = var.sam_repository
  github_branch        = var.sam_branch_name
  stack_name           = "${var.resource_tag_name}-stack-name"
  pipeline_name        = "sam-pipeline"

  codestar_connector_credentials = var.sam_codestar_connector_credentials
  pipeline_artifact_bucket       = "artifact-bucket"
}
