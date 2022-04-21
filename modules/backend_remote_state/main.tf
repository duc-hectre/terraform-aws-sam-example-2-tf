# -----------------------------------------------------
# S3 and Dynamo DB for Terraform backend remote state
# -----------------------------------------------------

# S3 bucket for Terraform state file
resource "aws_s3_bucket" "_" {
  # Naming with env parameter
  bucket        = "${var.environment}-${var.resource_tag_name}-${var.bucket_terraform_state_base_name}"
  force_destroy = false
}


resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket._.id
  acl    = "private"
}

resource "aws_s3_bucket_versioning" "_" {
  bucket = aws_s3_bucket._.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "_" {
  bucket = aws_s3_bucket._.id  
  policy = data.aws_iam_policy_document.terraform_remote_state_policy.json
}

resource "aws_s3_bucket_server_side_encryption_configuration" "_" {
  bucket = aws_s3_bucket._.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Creat Dynamo DB table for locking session ID management
resource "aws_dynamodb_table" "_" {
  name           = "${var.environment}-${var.resource_tag_name}-${var.table_terraform_lock_base_name}"
  read_capacity  = 20 # Suitable for Terraform size lock infor
  write_capacity = 20 # Suitable for Terraform size lock infor
  hash_key       = "LockID"
  attribute {
    name = "LockID"
    type = "S" # String
  }
}
