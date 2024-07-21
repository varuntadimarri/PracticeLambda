
variable "topic_name" {
  description = "The name of the SNS topic"
  type        = string
}

variable "policy" {
  description = "The access policy for the SNS topic"
  type        = string
}

variable "sqs_endpoint" {
  description = "The ARN of the SQS queue to subscribe"
  type        = string
  default     = ""
}
