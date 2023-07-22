resource "aws_athena_workgroup" "taxidata" {
  name = "taxidata"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = false
    result_configuration {
      output_location = "s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/sql/"
    }
  }

  force_destroy = true
}

resource "aws_athena_named_query" "taxidata" {
  name        = "taxidata"
  description = "taxidata"
  workgroup   = aws_athena_workgroup.taxidata.name
  database    = aws_glue_catalog_database.nycitytaxi.name
  query       = <<EOF
Select * From "nycitytaxi"."week3" limit 10;
  EOF
}
