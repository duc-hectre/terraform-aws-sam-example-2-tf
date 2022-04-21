# -----------------------------------------------
# Output result Terraform remote state configure 
# -----------------------------------------------

output "s3_terraform_state_arn" {
  value       = aws_s3_bucket._.arn
  description = "The ARN of the S3 bucket"
}

output "s3_terraform_state_bucket" {
  value       = aws_s3_bucket._.bucket
  description = "The ARN of the S3 bucket"
}
output "dynamodb_terraform_lock_name" {
  value       = aws_dynamodb_table._.name
  description = "The name of the DynamoDB table"
}
