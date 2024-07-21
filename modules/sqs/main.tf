
resource "aws_sqs_queue" "this" {
  name = var.queue_name

  policy = var.policy
}

resource "aws_lambda_event_source_mapping" "sqs_event_source" {
  event_source_arn = aws_sqs_queue.this.arn
  function_name    = var.lambda_function_arn
  enabled          = true
  batch_size       = 10
  count            = var.lambda_function_arn != "" ? 1 : 0
}

