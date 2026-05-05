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
