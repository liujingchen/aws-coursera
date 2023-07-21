resource "aws_api_gateway_rest_api" "poc_api" {
  name = "sensor-data"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "poc" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "poc"
}

resource "aws_api_gateway_method" "poc_post" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.poc.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "poc" {
  rest_api_id             = aws_api_gateway_rest_api.poc_api.id
  resource_id             = aws_api_gateway_resource.poc.id
  http_method             = aws_api_gateway_method.poc_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = aws_lambda_function.lambda_function_poc.invoke_arn

}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_resource.poc.id
  http_method = aws_api_gateway_method.poc_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "poc_order" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_resource.poc.id
  http_method = aws_api_gateway_method.poc_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code

  # Need this otherwise will fail
  depends_on = [
    aws_api_gateway_integration.poc
  ]
}
