# main.tf
provider "aws" {
  region = "us-east-1"  # Change to your desired region
}

module "source_bucket" {
  source      = "./modules/s3"
  bucket_name = "practice-source-bucket1"
   bucket_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::654654534105:role/MyLambdaRole1"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::practice-source-bucket1/*"
        }
    ]
  })
  sns_topic_arn = module.sns_topic.sns_topic_arn
  is_source_bucket = true
}

module "target_bucket" {
  source      = "./modules/s3"
  bucket_name = "practice-target-bucket2"
  is_source_bucket = false 
  bucket_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::654654534105:role/MyLambdaRole1"
            },
            "Action": [
                "s3:GetObject",
                "s3:PutObject"
            ],
            "Resource": "arn:aws:s3:::practice-target-bucket2/*"
        }
    ]
  })
  sns_topic_arn = ""
}

resource "aws_iam_policy" "MyLambdaPolicy1" {
  name        = "MyLambdaPolicy1"
  description = "IAM policy for Lambda functions"
  policy      = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
          "sqs:DeleteMessage",
          "logs:CreateLogStream",
          "sqs:ReceiveMessage",
          "sqs:GetQueueAttributes",
          "logs:PutLogEvents"
        ],
        "Resource": [
          "arn:aws:sqs:us-east-1:654654534105:image_queue1",
          "arn:aws:logs:*:654654534105:log-group:/aws/lambda/mylambda1:*"
        ]
      },
      {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
          "sqs:ReceiveMessage",
          "logs:CreateLogGroup"
        ],
        "Resource": [
          "arn:aws:logs:us-east-1:654654534105:*",
          "arn:aws:sqs:us-east-1:654654534105:image_queue1"
        ]
      },
      {
        "Sid": "Statement1",
        "Effect": "Allow",
        "Action": [
          "logs:CreateLogGroup"
        ],
        "Resource": [
          "arn:aws:logs:*:654654534105:log-group:*"
        ]
      },
      {
        "Sid": "Statement2",
        "Effect": "Allow",
        "Action": [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        "Resource": [
          "arn:aws:s3:::practice-source-bucket1",
          "arn:aws:s3:::practice-source-bucket1/*",
          "arn:aws:s3:::practice-target-bucket2/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "MyLambdaRole1" {
  name = "MyLambdaRole1"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "MyLambdaPolicy1_attachment" {
  role       = aws_iam_role.MyLambdaRole1.name
  policy_arn = aws_iam_policy.MyLambdaPolicy1.arn
}

data "archive_file" "lambda_function_zip" {
  type        = "zip"
  source_file = "${path.module}/app.py"
  output_path = "${path.module}/lambda_function.zip"
}

module "lambda_function" {
  source        = "./modules/lambda"
  function_name = "mylambda1"
  handler       = "app.lambda_handler"
  role          = aws_iam_role.MyLambdaRole1.arn
  runtime       = "python3.9"
  layer_arns    = ["arn:aws:lambda:us-east-1:770693421928:layer:Klayers-p39-pillow:1"]
  filename      = data.archive_file.lambda_function_zip.output_path
}

module "sns_topic" {
  source      = "./modules/sns"
  topic_name  = "image_topic1"
  policy      = jsonencode({
    "Version": "2008-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
      {
        "Sid": "__default_statement_ID",
        "Effect": "Allow",
        "Principal": {
          "Service": "s3.amazonaws.com"
        },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:us-east-1:654654534105:image_topic1",
        "Condition": {
          "StringEquals": {
            "aws:SourceAccount": "654654534105"
          },
          "ArnLike": {
            "aws:SourceArn": "arn:aws:s3:*:*:practice-source-bucket1"
          }
        }
      },
      {
        "Sid": "sqs_statement",
        "Effect": "Allow",
        "Principal": {
          "Service": "sqs.amazonaws.com"
        },
        "Action": "sns:Subscribe",
        "Resource": "arn:aws:sns:us-east-1:654654534105:image_topic1",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "arn:aws:sqs:us-east-1:654654534105:image_queue1"
          }
        }
      }
    ]
  })
  sqs_endpoint = module.sqs_queue.sqs_queue_arn
}

module "sqs_queue" {
  source      = "./modules/sqs"
  queue_name  = "image_queue1"
  policy      = jsonencode({
    "Version": "2008-10-17",
    "Id": "__default_policy_ID",
    "Statement": [
      {
        "Sid": "Stmt1234",
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": [
          "sqs:ReceiveMessage",
          "sqs:sendMessage"
        ],
        "Resource": "arn:aws:sqs:us-east-1:654654534105:image_queue1",
        "Condition": {
          "ArnEquals": {
            "aws:SourceArn": "arn:aws:lambda:us-east-1:654654534105:mylambda1"
          }
        }
      },
      {
        "Sid": "Stmt12345",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "sqs:SendMessage",
        "Resource": "arn:aws:sqs:us-east-1:654654534105:image_queue1",
        "Condition": {
          "ArnLike": {
            "aws:SourceArn": "arn:aws:sns:us-east-1:654654534105:image_topic1"
          }
        }
      }
    ]
  })
   lambda_function_arn = module.lambda_function.lambda_function_arn
}
