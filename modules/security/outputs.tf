output "kms_key_arn" {
  description = "ARN of the general KMS key"
  value       = aws_kms_key.general.arn
}

output "dynamodb_kms_key_arn" {
  description = "ARN of the DynamoDB KMS key"
  value       = aws_kms_key.dynamodb.arn
}

output "lambda_role_arn" {
  description = "ARN of the Lambda execution role"
  value       = aws_iam_role.lambda_role.arn
}

output "iot_role_arn" {
  description = "ARN of the IoT role"
  value       = aws_iam_role.iot_role.arn
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.asu_alb_sg.id
}

output "app_sg_id" {
  description = "App Security Group ID"
  value       = aws_security_group.asu_app_sg.id
}

output "db_sg_id" {
  description = "DB Security Group ID"
  value       = aws_security_group.asu_db_sg.id
}

output "lambda_sg_id" {
  description = "Lambda Security Group ID"
  value       = aws_security_group.asu_lambda_sg.id
}

output "web_acl_arn" {
  description = "ARN of the CloudFront WAF WebACL"
  value       = aws_wafv2_web_acl.web_acl.arn
}

output "config_recorder_id" {
  description = "ID of the AWS Config recorder"
  value       = aws_config_configuration_recorder.config_recorder.id
}

output "config_rule_names" {
  description = "Names of the AWS Config managed rules"
  value = [
    aws_config_config_rule.s3_bucket_public_read_prohibited.name,
    aws_config_config_rule.root_account_mfa_enabled.name,
    aws_config_config_rule.encrypted_volumes.name,
    aws_config_config_rule.iam_password_policy.name,
    aws_config_config_rule.cloudtrail_enabled.name,
  ]
}
