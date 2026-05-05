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

output "dashboard_name" {
  description = "CloudWatch dashboard name"
  value       = module.monitoring.dashboard_name
}

output "guardduty_detector_id" {
  description = "GuardDuty detector ID"
  value       = module.monitoring.guardduty_detector_id
}
