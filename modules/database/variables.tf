variable "random_suffix" {
  description = "Random suffix to make bucket names unique"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to S3 buckets"
  type        = map(string)
  default     = {}
}

variable "dynamodb_kms_key_arn" {
  description = "KMS key ARN to use for DynamoDB server-side encryption"
  type        = string
}
