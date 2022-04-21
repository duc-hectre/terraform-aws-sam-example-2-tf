# ----------------------------------------------
# Terraform remote state backend IAM definition 
# ----------------------------------------------

# Terraform user
data "aws_iam_user" "terraform" {
  user_name = var.terraform_user
}

# Grant read/write access to the terraform user

data "aws_iam_policy_document" "terraform_remote_state_policy" {
  statement {
    actions = ["s3:*"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_iam_user.terraform.arn]
    }
    effect    = "Allow"
    resources = ["arn:aws:s3:::${aws_s3_bucket._.bucket}/*"]
  }
}

# Strict rules for un-authorize access
resource "aws_s3_bucket_public_access_block" "s3-tfremotestate" {
  bucket = aws_s3_bucket._.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Policy for DynamoDB
data "aws_iam_policy_document" "terraform_remote_lock_policy" {
  statement {
    actions   = ["dynamodb:*"]
    effect    = "Allow"
    resources = [aws_dynamodb_table._.arn]
  }
}

resource "aws_iam_user_policy" "terraform_user_db_table_policy" {
  name   = "${var.environment}-${var.resource_tag_name}-tf-dynamo-policy"
  user   = data.aws_iam_user.terraform.user_name
  policy = data.aws_iam_policy_document.terraform_remote_lock_policy.json
}
