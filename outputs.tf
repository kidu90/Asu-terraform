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
  value       = var.region
}

output "environment" {
  description = "Environment name"
  value       = var.environment
}
