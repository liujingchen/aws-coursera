resource "aws_iam_policy" "lambda_write_dynamoDB" {
  name   = "Lambda-Write-DynamoDB"
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Sid": "VisualEditor0",
          "Effect": "Allow",
          "Action": [
              "dynamodb:PutItem",
              "dynamodb:DescribeTable"
          ],
          "Resource": "*"
      }
  ]
}
  EOT
}

resource "aws_iam_policy" "lambda_sns_publish" {
  name   = "Lambda-SNS-Publish"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sns:Publish",
                "sns:GetTopicAttributes",
                    "sns:ListTopics"
            ],
                "Resource": "*"
        }
    ]
 }
  EOT
}

resource "aws_iam_policy" "lambda_dynamoDBStreams_read" {
  name   = "Lambda-DynamoDBStreams-Read"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeStream",
                "dynamodb:ListStreams",
                "dynamodb:GetRecords"
            ],
            "Resource": "*"
        }
    ]
}
  EOT
}


resource "aws_iam_policy" "lambda_read_sqs" {
  name   = "Lambda-Read-SQS"
  policy = <<EOT
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "sqs:DeleteMessage",
                "sqs:ReceiveMessage",
                "sqs:GetQueueAttributes",
                "sqs:ChangeMessageVisibility"
            ],
            "Resource": "*"
        }
    ]
}
  EOT
}

data "aws_iam_policy_document" "lambda_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_sqs_dynamoDB" {
  name               = "Lambda-SQS-DynamoDB"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_write_dynamoDB" {
  role       = aws_iam_role.lambda_sqs_dynamoDB.name
  policy_arn = aws_iam_policy.lambda_write_dynamoDB.arn
}

resource "aws_iam_role_policy_attachment" "lambda_read_sqs" {
  role       = aws_iam_role.lambda_sqs_dynamoDB.name
  policy_arn = aws_iam_policy.lambda_read_sqs.arn
}


resource "aws_iam_role" "lambda_dynamoDBStreams_sns" {
  name               = "Lambda-DynamoDBStreams-SNS"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_publish_sns" {
  role       = aws_iam_role.lambda_dynamoDBStreams_sns.name
  policy_arn = aws_iam_policy.lambda_sns_publish.arn
}

resource "aws_iam_role_policy_attachment" "lambda_read_dynamoDBStream" {
  role       = aws_iam_role.lambda_dynamoDBStreams_sns.name
  policy_arn = aws_iam_policy.lambda_dynamoDBStreams_read.arn
}

data "aws_iam_policy_document" "apigateway_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda_apigateway_sqs" {
  name               = "APIGateway-SQS"
  assume_role_policy = data.aws_iam_policy_document.apigateway_assume_role.json
}

resource "aws_iam_role_policy_attachment" "apigateway_push_to_cloudwatch" {
  role       = aws_iam_role.lambda_apigateway_sqs.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}
