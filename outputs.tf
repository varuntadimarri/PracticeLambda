# outputs.tf
output "source_bucket_id" {
  value = module.source_bucket.bucket_id
}

output "source_bucket_arn" {
  value = module.target_bucket.bucket_arn
}

output "target_bucket_id" {
  value = module.target_bucket.bucket_id
}

output "target_bucket_arn" {
  value = module.target_bucket.bucket_arn
}

output "MyLambdaPolicy1_arn" {
  value = aws_iam_policy.MyLambdaPolicy1.arn
}

output "MyLambdaRole1_arn" {
  value = aws_iam_role.MyLambdaRole1.arn
}
output "mylambda1_arn" {
  value = module.lambda_function.lambda_function_arn
}

output "sns_topic_arn" {
  value = module.sns_topic.sns_topic_arn
}

output "sns_subscription_id" {
  value = module.sns_topic.sns_subscription_id
}

output "sqs_queue_arn" {
  value = module.sqs_queue.sqs_queue_arn
}

output "sqs_queue_url" {
  value = module.sqs_queue.sqs_queue_url
}