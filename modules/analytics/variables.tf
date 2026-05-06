variable "raw_telemetry_bucket" {
  description = "S3 bucket name for raw telemetry data"
  type        = string
}

variable "raw_telemetry_bucket_arn" {
  description = "ARN of the S3 bucket for raw telemetry data"
  type        = string
}

variable "processed_data_bucket" {
  description = "S3 bucket name for processed data"
  type        = string
}

variable "processed_data_bucket_arn" {
  description = "ARN of the S3 bucket for processed data"
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN for encryption"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to analytics resources"
  type        = map(string)
  default     = {}
}
