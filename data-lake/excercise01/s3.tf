resource "aws_s3_bucket" "datalake_bucket" {
  bucket        = "datalake-week2-ljc"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "datalake_bucket_policy" {
  bucket = aws_s3_bucket.datalake_bucket.id
  policy = data.aws_iam_policy_document.datalake_bucket_policy.json
}

data "aws_iam_policy_document" "datalake_bucket_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.lambda_role.arn}"]
    }

    actions = [
      "s3:*"
    ]

    resources = [
      aws_s3_bucket.datalake_bucket.arn,
      "${aws_s3_bucket.datalake_bucket.arn}/*",
    ]
  }
}
