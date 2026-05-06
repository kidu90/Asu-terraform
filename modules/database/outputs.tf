output "raw_telemetry_bucket" {
  description = "Name of the raw telemetry S3 bucket"
  value       = aws_s3_bucket.raw_telemetry.bucket
}

output "processed_data_bucket" {
  description = "Name of the processed data S3 bucket"
  value       = aws_s3_bucket.processed_data.bucket
}

output "cloudtrail_bucket" {
  description = "Name of the cloudtrail S3 bucket"
  value       = aws_s3_bucket.cloudtrail.bucket
}

output "raw_telemetry_bucket_arn" {
  description = "ARN of the raw telemetry bucket"
  value       = aws_s3_bucket.raw_telemetry.arn
}

output "cloudtrail_bucket_arn" {
  description = "ARN of the cloudtrail bucket"
  value       = aws_s3_bucket.cloudtrail.arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for meter telemetry"
  value       = aws_dynamodb_table.meter_telemetry.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for meter telemetry"
  value       = aws_dynamodb_table.meter_telemetry.arn
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = aws_rds_cluster.aurora.endpoint
}

output "aurora_reader_endpoint" {
  description = "Aurora cluster reader endpoint"
  value       = aws_rds_cluster.aurora.reader_endpoint
}

output "aurora_cluster_id" {
  description = "Aurora cluster ID"
  value       = aws_rds_cluster.aurora.id
}

output "aurora_database_name" {
  description = "Aurora database name"
  value       = aws_rds_cluster.aurora.database_name
}
