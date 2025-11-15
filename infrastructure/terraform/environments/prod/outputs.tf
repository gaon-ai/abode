output "mwaa_environment_arn" {
  description = "ARN of the MWAA environment"
  value       = module.mwaa.mwaa_environment_arn
}

output "mwaa_webserver_url" {
  description = "Webserver URL of the MWAA environment"
  value       = module.mwaa.mwaa_webserver_url
}

output "mwaa_execution_role_arn" {
  description = "Execution role ARN for MWAA"
  value       = module.mwaa.mwaa_execution_role_arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for MWAA"
  value       = module.mwaa.s3_bucket_name
}

output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}
