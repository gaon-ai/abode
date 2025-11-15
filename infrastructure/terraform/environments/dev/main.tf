terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# Get default subnets
data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# MWAA Module
module "mwaa" {
  source = "../../modules/mwaa"

  environment_name = "${var.project_name}-${var.environment}"
  environment      = var.environment

  vpc_id             = data.aws_vpc.default.id
  private_subnet_ids = data.aws_subnets.default.ids
}
