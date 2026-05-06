variable "public_subnet_ids" {
  description = "List of public subnet IDs to attach the ALB"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID where target groups will be created"
  type        = string
}

variable "alb_sg_id" {
  description = "Security group ID to attach to the ALB"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "private_app_subnet_ids" {
  description = "List of private app subnet IDs for ECS service placement"
  type        = list(string)
}

variable "app_sg_id" {
  description = "Security group ID for ECS tasks"
  type        = string
}

variable "dynamodb_table_name" {
  description = "DynamoDB table name for ECS tasks"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  type        = string
}

variable "raw_telemetry_bucket_arn" {
  description = "ARN of the raw telemetry S3 bucket"
  type        = string
}

variable "sqs_queue_url" {
  description = "URL of the SQS queue"
  type        = string
}

variable "sqs_queue_arn" {
  description = "ARN of the SQS queue"
  type        = string
}

variable "sns_topic_arn" {
  description = "ARN of the SNS topic"
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of the KMS key for encryption"
  type        = string
}

variable "tags" {
  description = "Tags to apply to ALB resources"
  type        = map(string)
  default     = {}
}
