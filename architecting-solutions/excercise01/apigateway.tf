resource "aws_api_gateway_rest_api" "poc_api" {
  name = "POC-API"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "order" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  parent_id   = aws_api_gateway_rest_api.poc_api.root_resource_id
  path_part   = "order"
}

resource "aws_api_gateway_method" "order_post" {
  rest_api_id   = aws_api_gateway_rest_api.poc_api.id
  resource_id   = aws_api_gateway_resource.order.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "poc_order" {
  rest_api_id             = aws_api_gateway_rest_api.poc_api.id
  resource_id             = aws_api_gateway_resource.order.id
  http_method             = aws_api_gateway_method.order_post.http_method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:sqs:path/${data.aws_caller_identity.self.account_id}/${aws_sqs_queue.poc_queue.name}"
  credentials             = aws_iam_role.lambda_apigateway_sqs.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }
  passthrough_behavior = "NEVER"
  request_templates = {
    "application/json" = <<EOF
Action=SendMessage&MessageBody=$input.body
    EOF
  }
}

resource "aws_api_gateway_method_response" "response_200" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.order_post.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "MyDemoIntegrationResponse" {
  rest_api_id = aws_api_gateway_rest_api.poc_api.id
  resource_id = aws_api_gateway_resource.order.id
  http_method = aws_api_gateway_method.order_post.http_method
  status_code = aws_api_gateway_method_response.response_200.status_code
}
