# Backend configuration for Terraform state
# Uncomment and configure after creating the state bucket

# terraform {
#   backend "s3" {
#     bucket         = "abode-terraform-state-dev"
#     key            = "flinks-ingestion/dev/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "abode-terraform-locks"
#   }
# }
