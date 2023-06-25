data "archive_file" "lambda1" {
  type        = "zip"
  source_file = "lambda_function_1.py"
  output_path = "lambda_function_1_payload.zip"
}

resource "aws_lambda_function" "lambda_function_1" {
  filename      = "lambda_function_1_payload.zip"
  function_name = "POC-Lambda-1"
  role          = aws_iam_role.lambda_sqs_dynamoDB.arn
  handler       = "lambda_function_1.lambda_handler"

  source_code_hash = data.archive_file.lambda1.output_base64sha256

  runtime = "python3.9"
}

resource "aws_lambda_event_source_mapping" "sqs_lambda_1" {
  event_source_arn = aws_sqs_queue.poc_queue.arn
  function_name    = aws_lambda_function.lambda_function_1.arn
}

data "archive_file" "lambda2" {
  type = "zip"
  source {
    content  = templatefile("${path.module}/lambda_function_2.py.tftpl", { topic_arn = aws_sns_topic.poc_topic.arn })
    filename = "lambda_function_2.py"
  }
  output_path = "lambda_function_2_payload.zip"
}

resource "aws_lambda_function" "lambda_function_2" {
  filename      = "lambda_function_2_payload.zip"
  function_name = "POC-Lambda-2"
  role          = aws_iam_role.lambda_dynamoDBStreams_sns.arn
  handler       = "lambda_function_2.lambda_handler"

  source_code_hash = data.archive_file.lambda2.output_base64sha256

  runtime = "python3.9"
}

resource "aws_lambda_event_source_mapping" "dynamoDB_lambda_2" {
  event_source_arn  = aws_dynamodb_table.orders.stream_arn
  function_name     = aws_lambda_function.lambda_function_2.arn
  starting_position = "LATEST"
}
