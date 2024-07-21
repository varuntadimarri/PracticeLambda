
variable "queue_name" {
  description = "The name of the SQS queue"
  type        = string
}

variable "policy" {
  description = "The access policy for the SQS queue"
  type        = string
}
variable "lambda_function_arn" {
  description = "The ARN of the Lambda function to trigger"
  type        = string
  default     = ""
}