provider "aws" {
  region = "ap-northeast-1"
}


data "aws_caller_identity" "self" {}

data "aws_region" "current" {}
