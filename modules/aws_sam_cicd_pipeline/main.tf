locals {
  resource_name_prefix = "${var.environment}-${var.resource_tag_name}"

  tags = {
    Environment = var.environment
    Name        = var.resource_tag_name
  }
}


resource "aws_sam_s3_bucket" "_" {
  bucket = var.pipeline_artifact_bucket
  # acl    = "private"
}

resource "aws_sam_s3_bucket_acl" "_" {
  bucket = aws_sam_s3_bucket._.id
  acl    = "private"
}


module "aws_sam_iam" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_pipeline_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${aws_codepipeline._.name}-pipeline-role"
  policy_name        = "${aws_codepipeline._.name}-pipeline-policy"
  role_vars          = {}
}


module "aws_iam_sam_codebuild" {
  source            = "../aws_iam"
  environment       = var.environment
  region            = var.region
  resource_tag_name = var.resource_tag_name

  assume_role_policy = file("${path.root}/policies/code_build_assume_role.json")
  template           = file("${path.root}/policies/cicd_policy.json")
  role_name          = "${aws_codepipeline._.name}-codebuild-role"
  policy_name        = "${aws_codepipeline._.name}-codebuild-policy"
  role_vars          = {}
}

