resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "this" {
  bucket = aws_s3_bucket.this.id
  policy = var.bucket_policy
  count  = var.bucket_policy != "" ? 1 : 0
}

resource "aws_s3_bucket_notification" "image_notify" {
  bucket = aws_s3_bucket.this.id
  
  topic {
    topic_arn = var.sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_s3_bucket_policy.this]
  count      = var.sns_topic_arn != "" ? 1 : 0
}
