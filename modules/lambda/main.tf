resource "aws_lambda_function" "this" {
  function_name = var.function_name
  handler       = var.handler
  role          = var.role
  runtime       = var.runtime
  filename      = var.filename

  layers = var.layer_arns

  source_code_hash = filebase64sha256(var.filename)
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.this.function_name}"
  retention_in_days = 14
}
