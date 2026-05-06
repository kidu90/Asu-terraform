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

variable "kms_key_arn" {
  description = "KMS key ARN for Aurora encryption"
  type        = string
}

variable "private_data_subnet_ids" {
  description = "Private data subnet IDs for Aurora DB subnet group"
  type        = list(string)
}

variable "db_sg_id" {
  description = "Security group ID for Aurora cluster"
  type        = string
}

variable "db_password" {
  description = "Master password for Aurora database"
  type        = string
  sensitive   = true
}

variable "availability_zones" {
  description = "Availability zones for Aurora cluster"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}
