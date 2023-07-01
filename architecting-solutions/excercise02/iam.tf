resource "aws_iam_policy" "api_firehose" {
  name   = "API-Firehose"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "firehose:PutRecord",
            "Resource": "*"
        }
    ]
}
  EOF
}

data "aws_iam_policy_document" "api_firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "api_firehose" {
  name               = "APIGateway-Firehose"
  assume_role_policy = data.aws_iam_policy_document.api_firehose_assume_role.json
}

resource "aws_iam_role_policy_attachment" "api_firehose" {
  role       = aws_iam_role.api_firehose.name
  policy_arn = aws_iam_policy.api_firehose.arn
}


resource "aws_iam_policy" "lambda_poc" {
  name   = "Lambda-Read-SQS"
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "logs:CreateLogGroup",
            "Resource": "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:log-group:/aws/lambda/test:*"
            ]
        }
    ]
}
  EOF
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

resource "aws_iam_role" "lambda_poc" {
  name               = "Lambda-POC"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_poc" {
  role       = aws_iam_role.lambda_poc.name
  policy_arn = aws_iam_policy.lambda_poc.arn
}


data "aws_iam_policy_document" "firehose_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_poc_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume_role.json
}

resource "aws_iam_policy" "firehose_invoke_lambda" {
  name   = "Firehose-Invoke-Lambda"
  policy = <<EOF
{
    "Version": "2012-10-17",  
    "Statement":
    [    
        {
           "Effect": "Allow", 
           "Action": [
               "lambda:InvokeFunction", 
               "lambda:GetFunctionConfiguration" 
           ],
           "Resource": [
               "arn:aws:lambda:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:function:*:*"
           ]
        }
    ]
}
  EOF
}

resource "aws_iam_role_policy_attachment" "firehose_invoke_lambda" {
  role       = aws_iam_role.firehose_role.name
  policy_arn = aws_iam_policy.firehose_invoke_lambda.arn
}
