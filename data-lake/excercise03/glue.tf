resource "aws_glue_catalog_database" "nycitytaxi" {
  name = "nycitytaxi"
}

resource "aws_glue_crawler" "nytaxicrawler" {
  database_name = aws_glue_catalog_database.nycitytaxi.name
  name          = "nytaxicrawler"
  role          = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/AWSGlueServiceRoleDefault"
  s3_target {
    path = "s3://aws-tc-largeobjects/DEV-AWS-MO-Designing_DataLakes/week3/"
  }
  depends_on = [aws_cloudformation_stack.week3]
}

data "aws_glue_script" "nytaxiparquet" {
  language = "PYTHON"

  dag_edge {
    source = "S3bucket_node1"
    target = "S3bucket_node2"
  }

  dag_node {
    id        = "S3bucket_node1"
    node_type = "DataSource"
    args {
      name  = "database"
      value = "\"${aws_glue_catalog_database.nycitytaxi.name}\""
    }

    args {
      name  = "table_name"
      value = "\"week3\""
    }
  }

  dag_node {
    id        = "S3bucket_node2"
    node_type = "DataSink"
    args {
      name  = "connection_type"
      value = "\"s3\""
    }

    args {
      name  = "format"
      value = "\"glueparquet\""
    }

    args {
      name  = "connection_options"
      value = "{\"path\": \"s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/data/\", \"partitionKeys\": []}"
    }
  }
}

resource "local_file" "nytaxiparquet" {
  content  = data.aws_glue_script.nytaxiparquet.python_script
  filename = "nytaxiparquet.py"
}

resource "aws_s3_object" "nytaxiparquet" {
  key        = "nytaxiparquet.py"
  bucket     = aws_cloudformation_stack.week3.outputs.S3Bucket
  source     = "${path.module}/${local_file.nytaxiparquet.filename}"
  depends_on = [aws_cloudformation_stack.week3, local_file.nytaxiparquet]
}

resource "aws_cloudwatch_log_group" "nytaxiparquet" {
  name              = "nytaxiparquet"
  retention_in_days = 14
}

resource "aws_glue_job" "nytaxiparquet" {
  name         = "nytaxiparquet"
  role_arn     = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/AWSGlueServiceRoleDefault"
  glue_version = "4.0"
  command {
    script_location = "s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/nytaxiparquet.py"
  }
  execution_class   = "STANDARD"
  number_of_workers = 10
  worker_type       = "G.1X"
  default_arguments = {
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.nytaxiparquet.name
    "--enable-metrics"                   = true
    "--job-language"                     = "python"
    "--enable-spark-ui"                  = true
    "--spark-event-logs-path"            = "s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/sparkHistoryLogs/"
    "--enable-job-insights"              = false
    "--enable-glue-datacatalog"          = true
    "--enable-continuous-cloudwatch-log" = true
    "--job-bookmark-option"              = "job-bookmark-disable"
    "--TempDir"                          = "s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/temporary/"
  }
}

resource "aws_glue_crawler" "nytaxiparquet" {
  database_name = aws_glue_catalog_database.nycitytaxi.name
  name          = "nytaxiparquet"
  role          = "arn:aws:iam::${data.aws_caller_identity.self.account_id}:role/AWSGlueServiceRoleDefault"
  s3_target {
    path = "s3://${aws_cloudformation_stack.week3.outputs.S3Bucket}/data/"
  }
  depends_on = [aws_cloudformation_stack.week3]
}