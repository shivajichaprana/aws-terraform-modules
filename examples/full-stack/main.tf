###############################################################################
# Full-Stack Example
# Deploys a complete VPC with public/private subnets, NAT Gateway,
# flow logs, and an encrypted S3 bucket for Terraform state.
###############################################################################

terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

###############################################################################
# VPC
###############################################################################

module "vpc" {
  source = "../../modules/vpc"

  name               = "${var.project_name}-${var.environment}"
  cidr               = "10.0.0.0/16"
  availability_zones = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  enable_nat_gateway = true
  single_nat_gateway = var.environment != "production"
  enable_flow_logs   = true

  tags = local.common_tags
}

###############################################################################
# S3 Bucket — Terraform State Backend
###############################################################################

module "terraform_state_bucket" {
  source = "../../modules/s3"

  bucket_name            = "${var.project_name}-${var.environment}-terraform-state"
  enable_versioning      = true
  enable_encryption      = true
  block_public_access    = true
  enable_lifecycle_rules = true

  noncurrent_version_expiration_days = 90
  transition_to_ia_days              = 90
  transition_to_glacier_days         = 180

  tags = local.common_tags
}

###############################################################################
# S3 Bucket — Application Assets
###############################################################################

module "assets_bucket" {
  source = "../../modules/s3"

  bucket_name         = "${var.project_name}-${var.environment}-assets"
  enable_versioning   = true
  enable_encryption   = true
  block_public_access = true

  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://*.${var.project_name}.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3600
    }
  ]

  tags = local.common_tags
}

###############################################################################
# Local Values
###############################################################################

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Repository  = "aws-terraform-modules"
  }
}
