data "archive_file" "lambda_poc" {
  type        = "zip"
  source_file = "lambda_function.py"
  output_path = "lambda_function_payload.zip"
}

resource "aws_lambda_function" "lambda_function_poc" {
  filename      = "lambda_function_payload.zip"
  function_name = "transform-data"
  role          = aws_iam_role.lambda_poc.arn
  handler       = "lambda_function.lambda_handler"

  source_code_hash = data.archive_file.lambda_poc.output_base64sha256

  runtime = "python3.8"
  timeout = 10
}
