resource "aws_s3_bucket" "poc_bucket" {
  bucket        = "architecting-week2-ljc"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "poc_policy" {
  bucket = aws_s3_bucket.poc_bucket.id
  policy = data.aws_iam_policy_document.poc_policy.json
}

data "aws_iam_policy_document" "poc_policy" {
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
      aws_s3_bucket.poc_bucket.arn,
      "${aws_s3_bucket.poc_bucket.arn}/*",
    ]
  }
}
