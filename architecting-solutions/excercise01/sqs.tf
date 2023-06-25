locals {
  sqs_name = "POC-Queue"
}

resource "aws_sqs_queue" "poc_queue" {
  name   = local.sqs_name
  policy = <<EOT
{
  "Version": "2012-10-17",
  "Id": "__default_policy_ID",
  "Statement": [
    {
      "Sid": "__owner_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": "${data.aws_caller_identity.self.account_id}"
      },
      "Action": [
        "SQS:*"
      ],
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:${local.sqs_name}"
    },
    {
      "Sid": "__sender_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_apigateway_sqs.arn}"
        ]
      },
      "Action": [
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:${local.sqs_name}"
    },
    {
      "Sid": "__receiver_statement",
      "Effect": "Allow",
      "Principal": {
        "AWS": [
          "${aws_iam_role.lambda_sqs_dynamoDB.arn}"
        ]
      },
      "Action": [
        "SQS:ChangeMessageVisibility",
        "SQS:DeleteMessage",
        "SQS:ReceiveMessage"
      ],
      "Resource": "arn:aws:sqs:${data.aws_region.current.name}:${data.aws_caller_identity.self.account_id}:${local.sqs_name}"
    }
  ]
}
    EOT

  # Need this otherwise will fail
  depends_on = [
    aws_lambda_function.lambda_function_1
  ]
}
