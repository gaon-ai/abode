# Backend configuration for Terraform state
# Uncomment and configure after creating the state bucket

# terraform {
#   backend "s3" {
#     bucket         = "abode-terraform-state"
#     key            = "flinks-ingestion/prod/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "abode-terraform-locks"
#   }
# }
