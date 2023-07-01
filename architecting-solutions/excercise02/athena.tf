resource "aws_athena_database" "poc" {
  name          = "clickstream_ingest_poc"
  bucket        = aws_s3_bucket.poc_bucket.bucket
  force_destroy = true
}

resource "aws_athena_workgroup" "poc" {
  name = "clickstream_ingest_poc"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    result_configuration {
      output_location = "s3://${aws_s3_bucket.poc_bucket.bucket}/athena-result/"
    }
  }

  force_destroy = true
}

resource "aws_athena_named_query" "create_table" {
  name        = "Create table"
  description = "Create PoC table"
  workgroup   = aws_athena_workgroup.poc.name
  database    = aws_athena_database.poc.name
  query       = <<EOF
CREATE EXTERNAL TABLE my_ingested_data (
element_clicked STRING,
time_spent INT,
source_menu STRING,
created_at STRING
)
PARTITIONED BY (
datehour STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
with serdeproperties ( 'paths'='element_clicked, time_spent, source_menu, created_at' )
LOCATION "s3://${aws_s3_bucket.poc_bucket.bucket}/"
TBLPROPERTIES (
"projection.enabled" = "true",
"projection.datehour.type" = "date",
"projection.datehour.format" = "yyyy/MM/dd/HH",
"projection.datehour.range" = "2021/01/01/00,NOW",
"projection.datehour.interval" = "1",
"projection.datehour.interval.unit" = "HOURS",
"storage.location.template" = "s3://${aws_s3_bucket.poc_bucket.bucket}/$${datehour}/"
)
  EOF
}
