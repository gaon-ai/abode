output "mwaa_environment_arn" {
  description = "ARN of the MWAA environment"
  value       = aws_mwaa_environment.this.arn
}

output "mwaa_environment_id" {
  description = "ID of the MWAA environment"
  value       = aws_mwaa_environment.this.id
}

output "mwaa_webserver_url" {
  description = "Webserver URL of the MWAA environment"
  value       = aws_mwaa_environment.this.webserver_url
}

output "mwaa_service_role_arn" {
  description = "Service role ARN of the MWAA environment"
  value       = aws_mwaa_environment.this.service_role_arn
}

output "mwaa_execution_role_arn" {
  description = "Execution role ARN for MWAA"
  value       = aws_iam_role.mwaa.arn
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket for MWAA"
  value       = aws_s3_bucket.mwaa.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for MWAA"
  value       = aws_s3_bucket.mwaa.arn
}

output "security_group_id" {
  description = "Security group ID for MWAA"
  value       = aws_security_group.mwaa.id
}

output "mwaa_status" {
  description = "Status of the MWAA environment"
  value       = aws_mwaa_environment.this.status
}
