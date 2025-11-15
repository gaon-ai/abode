terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      ManagedBy   = "Terraform"
      Project     = "Abode-Flinks-Ingestion"
    }
  }
}

# Call the s3-cross-account-ingestion module
module "flinks_ingestion" {
  source = "../../modules/s3-cross-account-ingestion"

  environment           = var.environment
  bucket_name           = var.bucket_name
  vendor_aws_account_id = var.vendor_aws_account_id
  external_id           = var.external_id

  data_prefix        = var.data_prefix
  test_prefix        = var.test_prefix
  enable_test_prefix = var.enable_test_prefix

  role_max_session_duration = var.role_max_session_duration
  enable_lifecycle_rules    = var.enable_lifecycle_rules
  glacier_transition_days   = var.glacier_transition_days
  data_retention_days       = var.data_retention_days

  enable_access_logging = var.enable_access_logging
  access_log_bucket     = var.access_log_bucket

  tags = var.tags
}
