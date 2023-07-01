resource "aws_api_gateway_rest_api" "poc_api" {
  name = "clickstream-ingest-poc"
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
  uri                     = "arn:aws:apigateway:${data.aws_region.current.name}:firehose:action/PutRecord"
  credentials             = aws_iam_role.api_firehose.arn
  request_parameters = {
    "integration.request.header.Content-Type" = "'application/json'"
  }
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
{
    "DeliveryStreamName": "${aws_kinesis_firehose_delivery_stream.poc_firehose.name}",
    "Record": {
        "Data": "$util.base64Encode($util.escapeJavaScript($input.json('$')).replace('\', ''))"
    }
}
    EOF
  }
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
