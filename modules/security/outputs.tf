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
