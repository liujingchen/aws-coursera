resource "aws_kinesis_firehose_delivery_stream" "poc_firehose_1" {
  name        = "web-log-ingestion-stream"
  destination = "extended_s3"

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.ingestion_bucket.arn
  }
}

resource "aws_kinesis_firehose_delivery_stream" "poc_firehose_2" {
  name        = "web-log-aggregated-data"
  destination = "opensearch"

  opensearch_configuration {
    domain_arn = aws_opensearch_domain.example.arn
    role_arn   = aws_iam_role.firehose_role.arn
    index_name = "request_data"

    s3_configuration {
      role_arn           = aws_iam_role.firehose_role.arn
      bucket_arn         = aws_s3_bucket.aggregated_bucket.arn
      buffering_size     = 1
      buffering_interval = 60
      compression_format = "GZIP"
    }
  }
}

resource "aws_cloudwatch_log_group" "analytics" {
  name = "analytics"
}

resource "aws_cloudwatch_log_stream" "analytics" {
  name           = "analytics-kinesis-application"
  log_group_name = aws_cloudwatch_log_group.analytics.name
}

resource "aws_kinesis_analytics_application" "aggregation_app" {
  name = "web-log-aggregation-app"
  cloudwatch_logging_options {
    log_stream_arn = aws_cloudwatch_log_stream.analytics.arn
    role_arn       = aws_iam_role.analystics_role.arn
  }

  inputs {
    name_prefix = "SOURCE_SQL_STREAM"
    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.poc_firehose_1.arn
      role_arn     = aws_iam_role.analystics_role.arn
    }

    schema {
      record_columns {
        mapping  = "$.host"
        name     = "host"
        sql_type = "VARCHAR(16)"
      }
      record_columns {
        mapping  = "$.datetime"
        name     = "datetime"
        sql_type = "VARCHAR(32)"
      }
      record_columns {
        mapping  = "$.request"
        name     = "request"
        sql_type = "VARCHAR(64)"
      }
      record_columns {
        mapping  = "$.response"
        name     = "response"
        sql_type = "INTEGER"
      }
      record_columns {
        mapping  = "$.bytes"
        name     = "bytes"
        sql_type = "INTEGER"
      }


      record_encoding = "UTF-8"

      record_format {
        mapping_parameters {
          json {
            record_row_path = "$"
          }
        }
      }
    }

    starting_position_configuration {
      starting_position = "NOW"
    }
  }

  outputs {
    name = "DESTINATION_SQL_STREAM"
    kinesis_firehose {
      resource_arn = aws_kinesis_firehose_delivery_stream.poc_firehose_2.arn
      role_arn     = aws_iam_role.analystics_role.arn
    }
    schema {
      record_format_type = "JSON"
    }
  }

  code = <<EOF
CREATE OR REPLACE STREAM "DESTINATION_SQL_STREAM"
  (datetime TIMESTAMP, status INTEGER, statusCount INTEGER);

CREATE OR REPLACE PUMP "STREAM_PUMP" AS INSERT INTO "DESTINATION_SQL_STREAM"
SELECT STREAM ROWTIME as datetime, "response" as status, COUNT(*) AS statusCount
FROM "SOURCE_SQL_STREAM_001"
GROUP BY "response",
FLOOR(("SOURCE_SQL_STREAM_001".ROWTIME - TIMESTAMP '1970-01-01 00:00:00') minute / 1 TO MINUTE);
  EOF

  start_application = true
}