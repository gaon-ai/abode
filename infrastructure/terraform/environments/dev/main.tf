terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Uncomment and configure backend for state management
  # backend "s3" {
  #   bucket         = "your-terraform-state-bucket"
  #   key            = "airflow/dev/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "terraform-state-lock"
  #   encrypt        = true
  # }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "dev"
      ManagedBy   = "Terraform"
      Project     = "Abode"
    }
  }
}

# VPC Module - you can use an existing VPC or create a new one
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.project_name}-mwaa-vpc-${var.environment}"
  cidr = var.vpc_cidr

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway = true
  enable_vpn_gateway = false
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "${var.project_name}-mwaa-vpc-${var.environment}"
  }
}

# MWAA Module
module "mwaa" {
  source = "../../modules/mwaa"

  environment_name = "${var.project_name}-${var.environment}"
  environment      = var.environment

  airflow_version   = var.airflow_version
  environment_class = var.environment_class
  max_workers       = var.max_workers
  min_workers       = var.min_workers
  schedulers        = var.schedulers

  webserver_access_mode = var.webserver_access_mode

  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnets

  dag_s3_path          = var.dag_s3_path
  requirements_s3_path = var.requirements_s3_path

  airflow_configuration_options = var.airflow_configuration_options
  logging_configuration         = var.logging_configuration

  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  tags = var.tags
}
