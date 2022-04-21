locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}


resource "aws_s3_bucket" "_" {
  bucket = "${local.resource_name_prefix}-${var.pipeline_artifact_bucket}-${var.pipeline_name}"
  # acl    = "private"
  force_destroy = true
}

resource "aws_s3_bucket_acl" "_" {
  bucket = aws_s3_bucket._.id
  acl    = "private"
}


module "aws_iam" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_pipeline_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${local.resource_name_prefix}-${var.pipeline_name}-pipeline-role"
  policy_name        = "${local.resource_name_prefix}-${var.pipeline_name}-pipeline-policy"
  role_vars          = {}
}


module "aws_iam_codebuild" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_build_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${local.resource_name_prefix}-${var.pipeline_name}-codebuild-role"
  policy_name        = "${local.resource_name_prefix}-${var.pipeline_name}-codebuild-policy"
  role_vars          = {}
}


resource "aws_codebuild_project" "tf_plan" {
  name        = "${local.resource_name_prefix}-${var.pipeline_name}-plan"
  description = "Plan state for terraform"

  service_role = module.aws_iam_codebuild.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    # registry_credential {
    #   credential          = var.dockerhub_credentials
    #   credential_provider = "SECRETS_MANAGER"
    # }
    environment_variable {
      name  = "BACKEND_CONFIG"
      value = "./environments/${var.environment}/${var.environment}.tfbackend"
    }
    environment_variable {
      name  = "TF_VARS"
      value = "./environments/${var.environment}/${var.environment}.tfvars"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/plan_buildspec.yml")
  }
}

resource "aws_codebuild_project" "tf_apply" {
  name        = "${local.resource_name_prefix}-${var.pipeline_name}-apply"
  description = "Apply state for terraform"

  service_role = module.aws_iam_codebuild.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "hashicorp/terraform:latest"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "SERVICE_ROLE"

    # registry_credential {
    #   credential          = var.dockerhub_credentials
    #   credential_provider = "SECRETS_MANAGER"
    # }
    environment_variable {
      name  = "BACKEND_CONFIG"
      value = "./environments/${var.environment}/${var.environment}.tfbackend"
    }
    environment_variable {
      name  = "TF_VARS"
      value = "./environments/${var.environment}/${var.environment}.tfvars"
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/apply_buildspec.yml")
  }
}


resource "aws_codepipeline" "_" {
  name     = "${local.resource_name_prefix}-${var.pipeline_name}"
  role_arn = module.aws_iam.role_arn

  artifact_store {
    type     = "S3"
    location = aws_s3_bucket._.bucket
  }

  stage {
    name = "Source"
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["${local.resource_name_prefix}-${var.pipeline_name}-code"]
      configuration = {
        FullRepositoryId     = var.github_repository_id
        BranchName           = var.github_branch
        ConnectionArn        = var.codestar_connector_credentials
        OutputArtifactFormat = "CODE_ZIP"
        DetectChanges        = true
      }
    }
  }

  stage {
    name = "Plan"
    action {
      name            = "Build"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["${local.resource_name_prefix}-${var.pipeline_name}-code"]
      configuration = {
        ProjectName = aws_codebuild_project.tf_plan.name
      }
    }
  }

  stage {
    name = "Deploy"
    action {
      name            = "Deploy"
      category        = "Build"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["${local.resource_name_prefix}-${var.pipeline_name}-code"]
      configuration = {
        ProjectName = aws_codebuild_project.tf_apply.name
      }
    }
  }
}
