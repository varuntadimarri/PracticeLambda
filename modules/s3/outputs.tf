output "source_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.source_bucket.arn
}

output "source_bucket_id" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.source_bucket.id
}

output "target_bucket_arn" {
  description = "The ARN of the S3 bucket."
  value       = aws_s3_bucket.target_bucket.arn
}

output "target_bucket_id" {
  description = "The name of the S3 bucket."
  value       = aws_s3_bucket.target_bucket.id
}
