variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "Tags to apply to all resources in the module"
  type        = map(string)
  default     = {}
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "name_prefix" {
  description = "Optional name prefix for resources"
  type        = string
  default     = ""
}

variable "on_prem_ip" {
  description = "On-premises public IP address for the customer gateway"
  type        = string
  default     = "1.2.3.4"
}
