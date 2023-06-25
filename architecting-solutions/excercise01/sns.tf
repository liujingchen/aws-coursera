resource "aws_sns_topic" "poc_topic" {
  name = "POC-Topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = aws_sns_topic.poc_topic.arn
  protocol  = "email"
  endpoint  = var.subscription_email
}
