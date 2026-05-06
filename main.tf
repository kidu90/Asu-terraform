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
  alias  = "us_east_1"
  region = "us-east-1"

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

provider "aws" {
  region = var.aws_region

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
  name_prefix            = "asu-dev"
  name_suffix            = random_id.this.hex
  cloudtrail_bucket_name = "${local.name_prefix}-cloudtrail-logs-${local.name_suffix}"
  cloudtrail_bucket_arn  = "arn:aws:s3:::${local.cloudtrail_bucket_name}"

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

data "aws_caller_identity" "current" {}

module "vpc" {
  source     = "./modules/vpc"
  on_prem_ip = var.on_prem_ip
  tags       = local.common_tags
}

module "security" {
  source                = "./modules/security"
  vpc_id                = module.vpc.vpc_id
  cloudtrail_bucket     = local.cloudtrail_bucket_name
  cloudtrail_bucket_arn = local.cloudtrail_bucket_arn
  tags                  = local.common_tags
  providers = {
    aws           = aws
    aws.us_east_1 = aws.us_east_1
  }
}

module "database" {
  source                  = "./modules/database"
  random_suffix           = random_id.this.hex
  dynamodb_kms_key_arn    = module.security.dynamodb_kms_key_arn
  kms_key_arn             = module.security.kms_key_arn
  private_data_subnet_ids = module.vpc.private_data_subnet_ids
  db_sg_id                = module.security.db_sg_id
  db_password             = var.db_password
  tags                    = local.common_tags
}

module "iot" {
  source                   = "./modules/iot"
  lambda_role_arn          = module.security.lambda_role_arn
  dynamodb_table_name      = module.database.dynamodb_table_name
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  lambda_sg_id             = module.security.lambda_sg_id
  iot_role_arn             = module.security.iot_role_arn
  raw_telemetry_bucket     = module.database.raw_telemetry_bucket
  raw_telemetry_bucket_arn = module.database.raw_telemetry_bucket_arn
  alert_email              = var.alert_email
  kms_key_arn              = module.security.kms_key_arn
  tags                     = local.common_tags
}

module "compute" {
  source                   = "./modules/compute"
  public_subnet_ids        = module.vpc.public_subnet_ids
  private_app_subnet_ids   = module.vpc.private_app_subnet_ids
  vpc_id                   = module.vpc.vpc_id
  alb_sg_id                = module.security.alb_sg_id
  app_sg_id                = module.security.app_sg_id
  dynamodb_table_name      = module.database.dynamodb_table_name
  dynamodb_table_arn       = module.database.dynamodb_table_arn
  raw_telemetry_bucket_arn = module.database.raw_telemetry_bucket_arn
  sqs_queue_url            = module.iot.sqs_queue_url
  sqs_queue_arn            = module.iot.sqs_queue_arn
  sns_topic_arn            = module.iot.sns_topic_arn
  kms_key_arn              = module.security.kms_key_arn
  tags                     = local.common_tags
}

resource "aws_wafv2_web_acl_association" "cloudfront" {
  provider = aws.us_east_1

  resource_arn = "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${module.compute.cloudfront_distribution_id}"
  web_acl_arn  = module.security.web_acl_arn
}

module "analytics" {
  source                    = "./modules/analytics"
  raw_telemetry_bucket      = module.database.raw_telemetry_bucket
  raw_telemetry_bucket_arn  = module.database.raw_telemetry_bucket_arn
  processed_data_bucket     = module.database.processed_data_bucket
  processed_data_bucket_arn = module.database.processed_data_bucket_arn
  kms_key_arn               = module.security.kms_key_arn
  tags                      = local.common_tags
}

module "monitoring" {
  source                = "./modules/monitoring"
  sns_topic_arn         = module.iot.sns_topic_arn
  cloudtrail_bucket     = module.database.cloudtrail_bucket
  cloudtrail_bucket_arn = module.database.cloudtrail_bucket_arn
  kms_key_arn           = module.security.kms_key_arn
  tags                  = local.common_tags
  sqs_queue_arn         = module.iot.sqs_queue_arn
  dynamodb_table_name   = module.database.dynamodb_table_name
}
