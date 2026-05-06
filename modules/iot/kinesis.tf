# Kinesis Data Stream for meter data ingestion
resource "aws_kinesis_stream" "meter_stream" {
  name             = "asu-${var.environment}-meter-stream"
  shard_count      = 2
  retention_period = 24

  tags = var.tags
}


# IAM Role for Firehose
resource "aws_iam_role" "firehose_role" {
  name = "asu-${var.environment}-firehose-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "firehose.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# IAM Policy for Firehose to access Kinesis, S3, and KMS
resource "aws_iam_role_policy" "firehose_policy" {
  name = "asu-${var.environment}-firehose-policy"
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "KinesisStreamAccess"
        Effect = "Allow"
        Action = [
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:DescribeStream",
          "kinesis:ListShards",
          "kinesis:ListStreams"
        ]
        Resource = aws_kinesis_stream.meter_stream.arn
      },
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_telemetry_bucket_arn,
          "${var.raw_telemetry_bucket_arn}/*"
        ]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:GenerateDataKey",
          "kms:Decrypt"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Kinesis Firehose Delivery Stream
resource "aws_kinesis_firehose_delivery_stream" "meter_to_s3" {
  name        = "asu-${var.environment}-meter-firehose"
  destination = "extended_s3"
  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.meter_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = var.raw_telemetry_bucket_arn

    prefix              = "raw/year=!{timestamp:yyyy}/month=!{timestamp:MM}/day=!{timestamp:dd}/"
    error_output_prefix = "errors/!{firehose:error-output-type}/"

    compression_format = "GZIP"

    s3_backup_mode = "Disabled"

    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_logs.name
      log_stream_name = aws_cloudwatch_log_stream.firehose_logs.name
    }

    processing_configuration {
      enabled = false
    }

    kms_key_arn = var.kms_key_arn
  }

  tags = var.tags

  depends_on = [aws_iam_role_policy.firehose_policy]
}

# CloudWatch Log Group for Firehose
resource "aws_cloudwatch_log_group" "firehose_logs" {
  name              = "/aws/kinesisfirehose/asu-${var.environment}-meter-firehose"
  retention_in_days = 7

  tags = var.tags
}

# CloudWatch Log Stream for Firehose
resource "aws_cloudwatch_log_stream" "firehose_logs" {
  name           = "S3Delivery"
  log_group_name = aws_cloudwatch_log_group.firehose_logs.name
}

# Lambda Event Source Mapping from Kinesis to Meter Processor
resource "aws_lambda_event_source_mapping" "kinesis_to_processor" {
  event_source_arn  = aws_kinesis_stream.meter_stream.arn
  function_name     = aws_lambda_function.meter_processor.arn
  enabled           = true
  starting_position = "LATEST"
  batch_size        = 100

  function_response_types = ["ReportBatchItemFailures"]

  maximum_retry_attempts         = 3
  bisect_batch_on_function_error = true
  maximum_record_age_in_seconds  = 604800 # 7 days

  depends_on = [aws_kinesis_stream.meter_stream]
}
