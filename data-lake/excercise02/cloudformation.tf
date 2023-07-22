resource "aws_cloudformation_stack" "week2" {
  name         = "week2-cloudformation"
  capabilities = ["CAPABILITY_NAMED_IAM"]
  template_url = "https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/DEV-AWS-MO-Designing_DataLakes/downloads/exercise-2-kinesis.yml"
}