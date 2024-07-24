variable "is_source_bucket" {
	description = "Indicates if the bucket is source_bucket"
	type = bool
	default = true
}



resource "aws_s3_bucket" "source_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket" "target_bucket" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

resource "aws_s3_bucket_policy" "source_policy" {
  bucket = aws_s3_bucket.source_bucket.id
  policy = var.bucket_policy
  count  = var.bucket_policy != "" ? 1 : 0
}

resource "aws_s3_bucket_policy" "target_policy" {
  bucket = aws_s3_bucket.target_bucket.id
  policy = var.bucket_policy
  count  = var.bucket_policy != "" ? 1 : 0
}

resource "aws_s3_bucket_notification" "image_notify" {
  bucket = aws_s3_bucket.source_bucket.id
  
  topic {
    topic_arn = var.sns_topic_arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_s3_bucket_policy.source_policy]
  count      = var.is_source_bucket == true ? 1 : 0
}

