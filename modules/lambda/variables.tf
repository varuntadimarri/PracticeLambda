# modules/lambda/variables.tf
variable "function_name" {
  description = "The name of the Lambda function"
  type        = string
}

variable "handler" {
  description = "The function entrypoint in your code"
  type        = string
}

variable "role" {
  description = "The ARN of the IAM role that Lambda assumes when it executes the function"
  type        = string
}

variable "runtime" {
  description = "The identifier of the function's runtime"
  type        = string
}

variable "layer_arns" {
  description = "List of Lambda Layer ARNs"
  type        = list(string)
}

variable "filename" {
  description = "The path to the ZIP file containing the Lambda function code"
  type        = string
}
