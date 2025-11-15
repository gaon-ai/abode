# Outputs to share with vendor and for reference

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = aws_s3_bucket.ingestion.id
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = aws_s3_bucket.ingestion.arn
}

output "bucket_region" {
  description = "AWS region where the bucket is located"
  value       = aws_s3_bucket.ingestion.region
}

output "vendor_role_arn" {
  description = "ARN of the IAM role for vendor to assume"
  value       = aws_iam_role.vendor_upload.arn
}

output "vendor_role_name" {
  description = "Name of the IAM role for vendor"
  value       = aws_iam_role.vendor_upload.name
}

output "data_prefix" {
  description = "S3 prefix where vendor should upload production data"
  value       = var.data_prefix
}

output "test_prefix" {
  description = "S3 prefix where vendor can upload test data (if enabled)"
  value       = var.enable_test_prefix ? var.test_prefix : null
}

output "external_id" {
  description = "External ID for AssumeRole (sensitive)"
  value       = var.external_id
  sensitive   = true
}

output "full_data_path" {
  description = "Full S3 path for data uploads"
  value       = "s3://${aws_s3_bucket.ingestion.id}/${var.data_prefix}/"
}

output "example_partition_path" {
  description = "Example partition path following the naming convention"
  value       = "s3://${aws_s3_bucket.ingestion.id}/${var.data_prefix}/dataset=login-ids/dt=YYYY-MM-DD/"
}

output "encryption_type" {
  description = "Server-side encryption type for uploaded objects"
  value       = "AES256"
}

output "role_session_duration_seconds" {
  description = "Maximum session duration for assumed role"
  value       = var.role_max_session_duration
}

# Summary for vendor integration guide
output "vendor_integration_summary" {
  description = "Summary of key information for vendor integration"
  value = {
    bucket_name         = aws_s3_bucket.ingestion.id
    bucket_region       = aws_s3_bucket.ingestion.region
    role_arn            = aws_iam_role.vendor_upload.arn
    data_prefix         = var.data_prefix
    test_prefix         = var.enable_test_prefix ? var.test_prefix : "not enabled"
    encryption          = "AES256 (SSE-S3)"
    max_session_seconds = var.role_max_session_duration
    example_path        = "s3://${aws_s3_bucket.ingestion.id}/${var.data_prefix}/dataset=login-ids/dt=YYYY-MM-DD/"
  }
}
