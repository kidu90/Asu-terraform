output "random_id_hex" {
  description = "Random ID in hexadecimal format for unique resource naming"
  value       = random_id.this.hex
}

output "random_id_dec" {
  description = "Random ID in decimal format"
  value       = random_id.this.dec
}

output "name_prefix" {
  description = "Common name prefix for resources"
  value       = local.name_prefix
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

output "aws_region" {
  description = "AWS region where resources are deployed"
  value       = var.aws_region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.database.dynamodb_table_name
}

output "sqs_queue_url" {
  description = "SQS queue URL"
  value       = module.iot.sqs_queue_url
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = module.iot.sns_topic_arn
}

output "iot_rule_name" {
  description = "IoT rule name"
  value       = module.iot.iot_rule_name
}

output "kinesis_stream_name" {
  description = "Kinesis Data Stream name for meter data"
  value       = module.iot.kinesis_stream_name
}

output "kinesis_stream_arn" {
  description = "Kinesis Data Stream ARN for meter data"
  value       = module.iot.kinesis_stream_arn
}

output "firehose_name" {
  description = "Kinesis Firehose delivery stream name"
  value       = module.iot.firehose_name
}

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.monitoring.guardduty_detector_id
}

output "alb_dns_name" {
  description = "DNS name of the Application Load Balancer"
  value       = module.compute.alb_dns_name
}

output "cloudfront_domain_name" {
  description = "CloudFront distribution domain name for portal access"
  value       = module.compute.cloudfront_domain_name
}

output "glue_database_name" {
  description = "Glue catalog database name for telemetry"
  value       = module.analytics.glue_database_name
}

output "crawler_name" {
  description = "Glue crawler name for telemetry raw data"
  value       = module.analytics.crawler_name
}

output "athena_workgroup_name" {
  description = "Athena workgroup name for telemetry queries"
  value       = module.analytics.athena_workgroup_name
}

output "notebook_instance_name" {
  description = "SageMaker notebook instance name for forecasting"
  value       = module.analytics.notebook_instance_name
}

output "notebook_instance_url" {
  description = "SageMaker notebook instance URL for forecasting"
  value       = module.analytics.notebook_instance_url
}
