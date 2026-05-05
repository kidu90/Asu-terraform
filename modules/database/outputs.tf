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
