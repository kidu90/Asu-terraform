# IAM Role for Glue
resource "aws_iam_role" "glue_role" {
  name = "asu-${var.environment}-glue-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# Attach AWS managed policy for Glue service
resource "aws_iam_role_policy_attachment" "glue_service_policy" {
  role       = aws_iam_role.glue_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole"
}

# Inline policy for S3 and KMS access
resource "aws_iam_role_policy" "glue_s3_kms_policy" {
  name = "asu-${var.environment}-glue-s3-kms-policy"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3Access"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "${var.raw_telemetry_bucket_arn}/*",
          "${var.processed_data_bucket_arn}/*"
        ]
      },
      {
        Sid    = "S3BucketAccess"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = [
          var.raw_telemetry_bucket_arn,
          var.processed_data_bucket_arn
        ]
      },
      {
        Sid    = "KMSAccess"
        Effect = "Allow"
        Action = [
          "kms:Decrypt",
          "kms:GenerateDataKey"
        ]
        Resource = var.kms_key_arn
      }
    ]
  })
}

# Glue Catalog Database
resource "aws_glue_catalog_database" "telemetry_db" {
  name = "asu_${replace(var.environment, "-", "_")}_telemetry_db"

  description = "Glue database for AquaSense meter telemetry data"

  tags = var.tags
}

# Glue Crawler for raw telemetry data
resource "aws_glue_crawler" "telemetry_crawler" {
  name          = "asu-${var.environment}-telemetry-crawler"
  database_name = aws_glue_catalog_database.telemetry_db.name
  role          = aws_iam_role.glue_role.arn
  schedule      = "cron(0 2 * * ? *)" # 2am daily

  s3_target {
    path = "s3://${var.raw_telemetry_bucket}/raw/"
  }

  schema_change_policy {
    update_behavior = "UPDATE_IN_DATABASE"
    delete_behavior = "DELETE_FROM_DATABASE"
  }

  tags = var.tags
}

# Glue ETL Job for JSON to Parquet conversion
resource "aws_glue_job" "json_to_parquet" {
  name     = "asu-${var.environment}-json-to-parquet"
  role_arn = aws_iam_role.glue_role.arn
  command {
    name            = "pythonshell"
    python_version  = "3.9"
    script_location = "s3://${var.processed_data_bucket}/scripts/etl.py"
  }

  default_arguments = {
    "--source_bucket"       = var.raw_telemetry_bucket
    "--dest_bucket"         = var.processed_data_bucket
    "--enable-job-insights" = "true"
    "--TempDir"             = "s3://${var.processed_data_bucket}/temp/"
  }

  max_capacity = 0.0625 # 1/16 DPU
  max_retries  = 1
  timeout      = 2880 # 48 hours

  tags = var.tags
}

# Athena Workgroup for SQL queries
resource "aws_athena_workgroup" "telemetry_workgroup" {
  name = "asu-${var.environment}-workgroup"

  configuration {
    result_configuration {
      output_location = "s3://${var.processed_data_bucket}/athena-results/"
      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }

    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    bytes_scanned_cutoff_per_query = 1073741824 # 1GB limit for cost control
  }

  tags = var.tags
}

# CloudWatch Log Group for Glue Job
resource "aws_cloudwatch_log_group" "glue_job_logs" {
  name              = "/aws/glue/jobs/asu-${var.environment}-json-to-parquet"
  retention_in_days = 7

  tags = var.tags
}
