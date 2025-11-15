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

module "airflow" {
  source = "../../modules/airflow-ec2"

  project_name = var.project_name
  environment  = var.environment
  ssh_key_name = var.ssh_key_name

  instance_type = var.instance_type
  volume_size   = var.volume_size

  allowed_ssh_cidr = var.allowed_ssh_cidr
  allowed_web_cidr = var.allowed_web_cidr
}
