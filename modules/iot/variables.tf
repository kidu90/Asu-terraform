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

variable "tags" {
  description = "Tags to apply to IoT messaging resources"
  type        = map(string)
  default     = {}
}
