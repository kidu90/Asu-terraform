variable "vpc_id" {
  description = "VPC ID where security groups will be created"
  type        = string
}

variable "cloudtrail_bucket" {
  description = "S3 bucket name used for AWS Config and CloudTrail delivery"
  type        = string
  default     = ""
}

variable "cloudtrail_bucket_arn" {
  description = "ARN of the S3 bucket used for AWS Config and CloudTrail delivery"
  type        = string
  default     = ""
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
  default     = null
}

variable "cloudfront_distribution_id" {
  description = "CloudFront distribution ID"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tags to apply to all resources in the module"
  type        = map(string)
  default     = {}
}
