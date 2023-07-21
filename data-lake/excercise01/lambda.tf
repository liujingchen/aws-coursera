resource "null_resource" "lambda_zip" {
  provisioner "local-exec" {
    command = "curl -o upload-data.zip https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/DEV-AWS-MO-Designing_DataLakes/downloads/upload-data.zip"
  }
}

resource "aws_lambda_function" "lambda_function_poc" {
  filename      = "upload-data.zip"
  function_name = "upload-data"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda.handler"

  runtime = "python3.9"
  timeout = 10

  environment {
    variables = {
      S3_BUCKET     = aws_s3_bucket.datalake_bucket.id
      ES_DOMAIN_URL = "https://${aws_opensearch_domain.example.endpoint}"
    }
  }

  depends_on = [null_resource.lambda_zip]
}

resource "aws_lambda_permission" "apigw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function_poc.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${aws_api_gateway_rest_api.poc_api.execution_arn}/*/*"
}
