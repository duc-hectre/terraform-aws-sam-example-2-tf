# -----------------------------------------
# Module: AWS_IAM output
# -----------------------------------------

output "role_arn" {
  value = one(aws_iam_role._.*.arn)
}
