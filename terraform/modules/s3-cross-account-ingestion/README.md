# S3 Cross-Account Ingestion Module

Terraform module for setting up secure cross-account S3 data ingestion from external vendors.

## Features

- **S3 bucket** with versioning, encryption (SSE-S3), and public access blocking
- **Cross-account IAM role** with least-privilege permissions
- **Bucket ownership controls** to ensure all objects are owned by the bucket owner
- **Lifecycle rules** for cost optimization (Glacier transition and expiration)
- **Optional test prefix** for vendor integration testing
- **Configurable session duration** for assumed role

## Architecture

```
┌─────────────────────┐
│  Vendor AWS Account │
│  (External)         │
└──────────┬──────────┘
           │
           │ AssumeRole
           │ (with ExternalId)
           │
           ▼
    ┌──────────────┐
    │  IAM Role    │
    │  (Our Acct)  │
    └──────┬───────┘
           │
           │ PutObject
           │ (login-ids/* prefix)
           │
           ▼
    ┌──────────────────┐
    │   S3 Bucket      │
    │   SSE-S3         │
    │   Versioned      │
    │   Private        │
    └──────────────────┘
```

## Usage

```hcl
module "flinks_ingestion" {
  source = "../../modules/s3-cross-account-ingestion"

  environment           = "prod"
  bucket_name           = "abode-flinks"
  vendor_aws_account_id = "123456789012"
  external_id           = "secure-random-string"

  data_prefix             = "login-ids"
  enable_test_prefix      = true
  test_prefix             = "test-login-ids"

  role_max_session_duration = 3600  # 1 hour
  data_retention_days       = 2555  # 7 years

  tags = {
    Team    = "Data Engineering"
    Vendor  = "Flinks"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name (dev, prod) | `string` | - | yes |
| bucket_name | Name of the S3 bucket | `string` | - | yes |
| vendor_aws_account_id | Vendor's AWS account ID | `string` | - | yes |
| external_id | External ID for AssumeRole | `string` | - | yes |
| data_prefix | S3 prefix for production data | `string` | `"login-ids"` | no |
| test_prefix | S3 prefix for test data | `string` | `"test-login-ids"` | no |
| enable_test_prefix | Grant vendor access to test prefix | `bool` | `false` | no |
| role_max_session_duration | Max session duration (seconds) | `number` | `3600` | no |
| enable_lifecycle_rules | Enable lifecycle rules | `bool` | `true` | no |
| glacier_transition_days | Days before Glacier transition | `number` | `90` | no |
| data_retention_days | Days before deletion | `number` | `2555` | no |
| enable_access_logging | Enable S3 access logging | `bool` | `false` | no |
| access_log_bucket | S3 bucket for access logs | `string` | `""` | no |
| tags | Additional tags | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| bucket_name | Name of the S3 bucket |
| bucket_arn | ARN of the S3 bucket |
| bucket_region | AWS region of the bucket |
| vendor_role_arn | ARN of the IAM role for vendor |
| vendor_role_name | Name of the IAM role |
| data_prefix | S3 prefix for production data |
| test_prefix | S3 prefix for test data |
| external_id | External ID (sensitive) |
| full_data_path | Full S3 path for uploads |
| example_partition_path | Example partition path |
| encryption_type | Encryption type (AES256) |
| vendor_integration_summary | Summary of vendor integration info |

## Security

- **No static credentials**: Vendor uses IAM role with AssumeRole
- **External ID**: Prevents confused deputy attacks
- **Least privilege**: Only PutObject and ListBucket on specific prefix
- **Encryption**: SSE-S3 by default
- **Versioning**: Enabled for data protection
- **Public access**: Blocked at bucket level
- **Object ownership**: BucketOwnerPreferred ensures we own all objects

## Data Contract

Vendor should upload files following this structure:

```
s3://bucket-name/login-ids/dataset=login-ids/dt=YYYY-MM-DD/login-ids_YYYYMMDD_part-0001.csv[.gz]
s3://bucket-name/login-ids/dataset=login-ids/dt=YYYY-MM-DD/_SUCCESS
```

- **Format**: CSV with header row, UTF-8, optionally gzipped
- **Atomicity**: Upload data files first, then `_SUCCESS` marker
- **Naming**: `login-ids_YYYYMMDD_part-####.csv[.gz]`

## Requirements

- Terraform >= 1.5.0
- AWS Provider >= 5.0

## License

Internal use only.
