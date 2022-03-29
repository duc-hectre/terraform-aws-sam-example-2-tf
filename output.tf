
output "dynamodb_name" {
  value = "${aws_dynamodb_table._.name}(${aws_dynamodb_table._.name})"
}
output "dynamodb_arn" {
  value = "${aws_dynamodb_table._.name}(${aws_dynamodb_table._.arn})"
}

output "sqs_name" {
  value = "${aws_sqs_queue._.name}(${aws_sqs_queue._.name})"
}

output "sqs_arn" {
  value = "${aws_sqs_queue._.name}(${aws_sqs_queue._.arn})"
}

output "cicd_pipeline_name" {
  value = module.aws_tf_cicd_pipeline.cicd_name
}
