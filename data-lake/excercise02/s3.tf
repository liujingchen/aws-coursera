resource "aws_s3_bucket" "ingestion_bucket" {
  bucket        = "datalake-week3-ljc-web-log-ingestion-bucket"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "ingestion_bucket_policy" {
  bucket = aws_s3_bucket.ingestion_bucket.id
  policy = data.aws_iam_policy_document.ingestion_policy.json
}

data "aws_iam_policy_document" "ingestion_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.firehose_role.arn}"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.ingestion_bucket.arn,
      "${aws_s3_bucket.ingestion_bucket.arn}/*",
    ]
  }
}

resource "aws_s3_bucket" "aggregated_bucket" {
  bucket        = "datalake-week3-ljc-web-log-aggregated-errors"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "aggregated_bucket_policy" {
  bucket = aws_s3_bucket.aggregated_bucket.id
  policy = data.aws_iam_policy_document.aggregated_policy.json
}

data "aws_iam_policy_document" "aggregated_policy" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.firehose_role.arn}"]
    }

    actions = [
      "s3:AbortMultipartUpload",
      "s3:GetBucketLocation",
      "s3:GetObject",
      "s3:ListBucket",
      "s3:ListBucketMultipartUploads",
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]

    resources = [
      aws_s3_bucket.aggregated_bucket.arn,
      "${aws_s3_bucket.aggregated_bucket.arn}/*",
    ]
  }
}