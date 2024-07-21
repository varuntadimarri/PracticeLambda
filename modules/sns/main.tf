
resource "aws_sns_topic" "this" {
  name = var.topic_name

  policy = var.policy
}

resource "aws_sns_topic_subscription" "sqs_subscription" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "sqs"
  endpoint  = var.sqs_endpoint
  count     = var.sqs_endpoint != "" ? 1 : 0
}