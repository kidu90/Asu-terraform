variable "kms_key_arn" {
  description = "KMS key ARN for SQS and SNS encryption"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "alert_email" {
  description = "Email address for SNS alerts"
  type        = string
}

variable "lambda_role_arn" {
  description = "IAM role ARN used by Lambda functions"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for meter telemetry"
  type        = string
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for alert notifications"
  type        = string
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN consumed by meter processor"
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private app subnet IDs for Lambda VPC configuration"
  type        = list(string)
}

variable "lambda_sg_id" {
  description = "Security group ID for Lambda VPC configuration"
  type        = string
}

variable "iot_role_arn" {
  description = "IAM role ARN used by IoT topic rule actions"
  type        = string
}

variable "raw_telemetry_bucket" {
  description = "S3 bucket name for raw telemetry ingestion"
  type        = string
}

variable "tags" {
  description = "Tags to apply to IoT messaging resources"
  type        = map(string)
  default     = {}
}
