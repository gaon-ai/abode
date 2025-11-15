# Output values from the module for reference

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.flinks_ingestion.bucket_name
}

output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.flinks_ingestion.bucket_arn
}

output "bucket_region" {
  description = "AWS region of the bucket"
  value       = module.flinks_ingestion.bucket_region
}

output "vendor_role_arn" {
  description = "ARN of the IAM role for vendor to assume"
  value       = module.flinks_ingestion.vendor_role_arn
}

output "vendor_role_name" {
  description = "Name of the IAM role"
  value       = module.flinks_ingestion.vendor_role_name
}

output "data_prefix" {
  description = "S3 prefix for production data"
  value       = module.flinks_ingestion.data_prefix
}

output "test_prefix" {
  description = "S3 prefix for test data"
  value       = module.flinks_ingestion.test_prefix
}

output "full_data_path" {
  description = "Full S3 path for data uploads"
  value       = module.flinks_ingestion.full_data_path
}

output "example_partition_path" {
  description = "Example partition path"
  value       = module.flinks_ingestion.example_partition_path
}

output "vendor_integration_summary" {
  description = "Summary for vendor integration"
  value       = module.flinks_ingestion.vendor_integration_summary
}

# Instructions for next steps
output "next_steps" {
  description = "Instructions for sharing with vendor"
  value = <<-EOT

    ===== SHARE WITH VENDOR =====

    1. Role ARN to assume: ${module.flinks_ingestion.vendor_role_arn}
    2. External ID: (retrieve with: terraform output -raw external_id)
    3. Bucket: ${module.flinks_ingestion.bucket_name}
    4. Region: ${module.flinks_ingestion.bucket_region}
    5. Data Prefix: ${module.flinks_ingestion.data_prefix}/
    6. Test Prefix: ${module.flinks_ingestion.test_prefix}/
    7. Encryption: AES256 (SSE-S3)
    8. Example Path: ${module.flinks_ingestion.example_partition_path}

    ==============================
  EOT
}

# Sensitive output - access separately
output "external_id" {
  description = "External ID for AssumeRole (sensitive)"
  value       = module.flinks_ingestion.external_id
  sensitive   = true
}
