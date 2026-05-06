variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "ap-south-1"
}

variable "region" {
  description = "Legacy alias for AWS region"
  type        = string
  default     = "ap-south-1"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for resource naming and tagging"
  type        = string
  default     = "aquasense"
}

variable "alert_email" {
  description = "Email address used for SNS alerts"
  type        = string
}

variable "db_password" {
  description = "Master password for Aurora database"
  type        = string
  sensitive   = true
}

variable "on_prem_ip" {
  description = "On-premises public IP address for the customer gateway"
  type        = string
  default     = "1.2.3.4"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
