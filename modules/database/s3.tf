# Raw telemetry bucket
resource "aws_s3_bucket" "raw_telemetry" {
  bucket = "asu-dev-raw-telemetry-${var.random_suffix}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "glacier-transition"
    enabled = true

    transition {
      days          = 90
      storage_class = "GLACIER"
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "raw_telemetry_block" {
  bucket                  = aws_s3_bucket.raw_telemetry.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Processed data bucket
resource "aws_s3_bucket" "processed_data" {
  bucket = "asu-dev-processed-data-${var.random_suffix}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "processed_data_block" {
  bucket                  = aws_s3_bucket.processed_data.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail logs bucket
resource "aws_s3_bucket" "cloudtrail" {
  bucket = "asu-dev-cloudtrail-logs-${var.random_suffix}"

  versioning {
    enabled = true
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "cloudtrail_block" {
  bucket                  = aws_s3_bucket.cloudtrail.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# CloudTrail bucket policy allowing CloudTrail to put objects
resource "aws_s3_bucket_policy" "cloudtrail_policy" {
  bucket = aws_s3_bucket.cloudtrail.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AWSCloudTrailWrite",
        Effect = "Allow",
        Principal = {
          Service = "cloudtrail.amazonaws.com"
        },
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = "${aws_s3_bucket.cloudtrail.arn}/*"
      }
    ]
  })
}
