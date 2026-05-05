variable "sns_topic_arn" {
  description = "SNS topic ARN used for alarm notifications"
  type        = string
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name used by CloudTrail"
  type        = string
}

variable "cloudtrail_bucket_arn" {
  description = "ARN of the CloudTrail S3 bucket"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN used for CloudTrail encryption"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to monitoring resources"
  type        = map(string)
  default     = {}
}

variable "sqs_queue_arn" {
  description = "SQS queue ARN for the meter events queue"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for the dashboard widget"
  type        = string
}
