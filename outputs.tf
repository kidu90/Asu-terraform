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

output "nat_gateway_ids" {
  description = "NAT gateway IDs"
  value       = module.vpc.nat_gateway_ids
}

output "eip_public_ips" {
  description = "Public IPs of NAT gateway Elastic IPs"
  value       = module.vpc.eip_public_ips
}

output "vpn_connection_id" {
  description = "Site-to-site VPN connection ID"
  value       = module.vpc.vpn_connection_id
}

output "vpn_connection_tunnel1_address" {
  description = "VPN tunnel 1 outside address"
  value       = module.vpc.vpn_connection_tunnel1_address
}

output "dynamodb_table_name" {
  description = "DynamoDB table name"
  value       = module.database.dynamodb_table_name
}

output "aurora_cluster_endpoint" {
  description = "Aurora cluster endpoint"
  value       = module.database.aurora_cluster_endpoint
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

output "web_acl_arn" {
  description = "WAF WebACL ARN"
  value       = module.security.web_acl_arn
}

output "config_recorder_id" {
  description = "AWS Config recorder ID"
  value       = module.security.config_recorder_id
}

output "config_rule_names" {
  description = "AWS Config managed rule names"
  value       = module.security.config_rule_names
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
