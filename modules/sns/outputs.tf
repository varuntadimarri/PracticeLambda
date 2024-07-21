# modules/sns/outputs.tf
output "sns_topic_arn" {
  description = "The ARN of the SNS topic"
  value       = aws_sns_topic.this.arn
}

output "sns_subscription_id" {
  description = "The ID of the SNS subscription"
  value       = aws_sns_topic_subscription.sqs_subscription[0].id
}
