provider "aws" {
  region = "us-east-1"
}


data "aws_caller_identity" "self" {}

data "aws_region" "current" {}