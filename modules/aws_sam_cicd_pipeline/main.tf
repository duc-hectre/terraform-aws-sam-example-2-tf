locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}


resource "aws_s3_bucket" "_" {
  bucket        = "${local.resource_name_prefix}-${var.pipeline_artifact_bucket}-${var.pipeline_name}"
  force_destroy = true
  # acl    = "private"
}

resource "aws_s3_bucket_acl" "_" {
  bucket = aws_s3_bucket._.id
  acl    = "private"
}


module "aws_sam_iam" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_pipeline_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${var.pipeline_name}-pipeline-role"
  policy_name        = "${var.pipeline_name}-pipeline-policy"
  role_vars          = {}
}


module "aws_iam_codebuild" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_build_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${var.pipeline_name}-codebuild-role"
  policy_name        = "${var.pipeline_name}-codebuild-policy"
  role_vars          = {}
}

module "aws_iam_cloudformation" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/cf_assume_role.json")
  template           = file("${path.root}/policies/cf_policy.json")
  role_name          = "${var.pipeline_name}-cf-role"
  policy_name        = "${var.pipeline_name}-cf-policy"
  role_vars = {
    codepipeline_role_arn = module.aws_sam_iam.role_arn
  }
}


resource "aws_codebuild_project" "sam_test" {
  name        = "${local.resource_name_prefix}-${var.pipeline_name}-test"
  description = "State to test lambda code using pytest"

  service_role = module.aws_iam_codebuild.role_arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/amazonlinux2-x86_64-standard:3.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # registry_credential {
    #   credential          = var.dockerhub_credentials
    #   credential_provider = "SECRETS_MANAGER"
    # }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/test_buildspec.yml")
  }
}

resource "aws_codebuild_project" "sam_build" {
  name        = "${local.resource_name_prefix}-${var.pipeline_name}-build"
  description = "Buid state for sam"

  service_role = module.aws_iam_codebuild.role_arn

  artifacts {
    type           = "CODEPIPELINE"
    namespace_type = "BUILD_ID"
    packaging      = "ZIP"
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "public.ecr.aws/sam/build-python3.8"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    # registry_credential {
    #   credential          = var.dockerhub_credentials
    #   credential_provider = "SECRETS_MANAGER"
    # }
    environment_variable {
      name  = "ARTIFACT_BUCKET"
      value = aws_s3_bucket._.bucket
    }
    environment_variable {
      name  = "SAM_VARS"
      value = var.sam_environment_vars
    }
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = file("${path.module}/buildspec/build_buildspec.yml")
  }
}

resource "aws_codepipeline" "_" {

  name     = "${local.resource_name_prefix}-${var.pipeline_name}"
  role_arn = module.aws_sam_iam.role_arn

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
      output_artifacts = ["${local.resource_name_prefix}-code"]
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
    name = "Test"
    action {
      name            = "Test"
      category        = "Test"
      provider        = "CodeBuild"
      version         = "1"
      owner           = "AWS"
      input_artifacts = ["${local.resource_name_prefix}-code"]
      # output_artifacts = ["tf-code-sam-build"]
      configuration = {
        ProjectName = aws_codebuild_project.sam_test.name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["${local.resource_name_prefix}-code"]
      output_artifacts = ["build"]

      configuration = {
        ProjectName = aws_codebuild_project.sam_build.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "CreateChangeSet"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build"]
      role_arn        = try(module.aws_iam_cloudformation.role_arn, "")
      version         = 1
      run_order       = 1

      configuration = {
        ActionMode            = "CHANGE_SET_REPLACE"
        Capabilities          = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND"
        OutputFileName        = "ChangeSetOutput.json"
        RoleArn               = try(module.aws_iam_cloudformation.role_arn, "")
        StackName             = "${local.resource_name_prefix}-${var.stack_name}"
        TemplatePath          = "build::packaged.yaml"
        ChangeSetName         = "${local.resource_name_prefix}-${var.stack_name}-deploy"
        TemplateConfiguration = "build::configuration.json"
      }
    }

    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "CloudFormation"
      input_artifacts = ["build"]
      version         = 1
      run_order       = 2

      configuration = {
        ActionMode     = "CHANGE_SET_EXECUTE"
        Capabilities   = "CAPABILITY_IAM,CAPABILITY_AUTO_EXPAND"
        OutputFileName = "ChangeSetExecuteOutput.json"
        StackName      = "${local.resource_name_prefix}-${var.stack_name}"
        ChangeSetName  = "${local.resource_name_prefix}-${var.stack_name}-deploy"
      }
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [stage[0].action[0].configuration]
  }
}
