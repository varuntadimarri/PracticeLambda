# bucket/variables.tf
variable "bucket_name" {
  description = "The name of the bucket"
  type        = string
}

variable "bucket_policy" {
  description = "The policy for the bucket"
  type        = string
  default     = ""
}

variable "sns_topic_arn" {
  description = "The ARN of the SNS topic for S3 event notifications"
  type        = string
  default     = ""
}