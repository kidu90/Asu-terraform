terraform {
  required_version = ">= 1.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.4"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Local values for common configuration
locals {
  name_prefix = "asu-dev"
  name_suffix = random_id.this.hex

  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    NamePrefix  = local.name_prefix
  }
}

# Generate random suffix for unique resource naming
resource "random_id" "this" {
  byte_length = 4
}
