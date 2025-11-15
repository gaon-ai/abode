# Abode Flinks Data Ingestion

Infrastructure as Code for secure cross-account data ingestion from Flinks vendor into Abode S3.

## Overview

This repository contains Terraform configurations to set up:
- **S3 bucket** for vendor data ingestion with encryption and versioning
- **Cross-account IAM role** for secure vendor access (no static credentials)
- **Lifecycle rules** for cost optimization (Glacier transition, retention)
- **Separate dev/prod environments** with environment-specific configurations

## Architecture

```
┌─────────────────────┐
│  Flinks AWS Account │
│  (Vendor)           │
└──────────┬──────────┘
           │
           │ AssumeRole with ExternalId
           │
           ▼
    ┌──────────────────┐
    │  IAM Role        │
    │  abode-flinks-   │
    │  vendor-upload   │
    └──────┬───────────┘
           │
           │ PutObject (login-ids/* only)
           │
           ▼
    ┌──────────────────────┐
    │   S3 Bucket          │
    │   abode-flinks       │
    │   - SSE-S3 encrypted │
    │   - Versioned        │
    │   - Private          │
    │   - Lifecycle rules  │
    └──────────────────────┘
```

## Repository Structure

```
abode/
├── terraform/
│   ├── modules/
│   │   └── s3-cross-account-ingestion/   # Reusable module
│   │       ├── main.tf                   # S3 bucket resources
│   │       ├── iam.tf                    # IAM role and policies
│   │       ├── variables.tf              # Input variables
│   │       ├── outputs.tf                # Output values
│   │       ├── versions.tf               # Provider requirements
│   │       └── README.md                 # Module documentation
│   │
│   └── environments/
│       ├── dev/                          # Development environment
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── backend.tf
│       │   └── terraform.tfvars.example
│       │
│       └── prod/                         # Production environment
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── backend.tf
│           └── terraform.tfvars.example
│
├── .gitignore
└── README.md
```

## Prerequisites

1. **Terraform** >= 1.5.0
2. **AWS CLI** configured with appropriate credentials
3. **AWS Account** with permissions to create:
   - S3 buckets
   - IAM roles and policies
4. **Vendor Information**:
   - Vendor's AWS Account ID
   - Agreed External ID (secret)

## Getting Started

### Step 1: Clone and Configure

```bash
cd terraform/environments/dev  # or prod
cp terraform.tfvars.example terraform.tfvars
```

### Step 2: Edit `terraform.tfvars`

```hcl
vendor_aws_account_id = "123456789012"  # Vendor's AWS account ID
external_id           = "secure-random-string-here"
aws_region            = "us-east-1"
```

**Important:** Generate a secure random External ID:
```bash
openssl rand -base64 32
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Plan and Apply

```bash
# Review changes
terraform plan

# Apply changes
terraform apply
```

### Step 5: Retrieve Outputs for Vendor

After successful deployment:

```bash
# View summary
terraform output vendor_integration_summary

# Get sensitive External ID
terraform output -raw external_id

# Get Role ARN
terraform output vendor_role_arn
```

## What to Share with Vendor

After deployment, share these details with Flinks:

1. **Role ARN**: `arn:aws:iam::<YOUR_ACCOUNT>:role/abode-flinks-vendor-upload`
2. **External ID**: (from `terraform output -raw external_id`)
3. **Bucket Name**: `abode-flinks` (or `abode-flinks-dev`)
4. **Region**: `us-east-1`
5. **Data Prefix**: `login-ids/`
6. **Encryption**: SSE-S3 (AES256)
7. **Expected Path Structure**:
   ```
   s3://abode-flinks/login-ids/dataset=login-ids/dt=YYYY-MM-DD/
   ```

## Data Contract

### File Format
- **Type**: CSV with header row
- **Encoding**: UTF-8
- **Delimiter**: Comma
- **Compression**: Optional `.gz`

### Schema
```csv
LoginID
user_123
user_456
```

### Naming Convention
```
login-ids_YYYYMMDD_part-0001.csv[.gz]
```

### Path Structure
```
s3://abode-flinks/login-ids/dataset=login-ids/dt=2025-10-14/login-ids_20251014_part-0001.csv.gz
s3://abode-flinks/login-ids/dataset=login-ids/dt=2025-10-14/_SUCCESS
```

### Atomicity
1. Upload all data files first
2. Upload `_SUCCESS` marker (zero-byte file) when batch is complete
3. Our systems only process partitions with `_SUCCESS` marker

## Vendor AssumeRole Example

```bash
# 1. Assume the role
aws sts assume-role \
  --role-arn arn:aws:iam::<YOUR_ACCOUNT>:role/abode-flinks-vendor-upload \
  --role-session-name flinks-upload-$(date +%Y%m%d) \
  --external-id <EXTERNAL_ID> \
  --duration-seconds 3600

# 2. Set temporary credentials
export AWS_ACCESS_KEY_ID=<from output>
export AWS_SECRET_ACCESS_KEY=<from output>
export AWS_SESSION_TOKEN=<from output>

# 3. Upload file
aws s3 cp login-ids_20251014_part-0001.csv.gz \
  s3://abode-flinks/login-ids/dataset=login-ids/dt=2025-10-14/ \
  --sse AES256

# 4. Upload success marker
touch _SUCCESS
aws s3 cp _SUCCESS \
  s3://abode-flinks/login-ids/dataset=login-ids/dt=2025-10-14/_SUCCESS \
  --sse AES256
```

## Environments

### Development (`dev`)
- Bucket: `abode-flinks-dev`
- Test prefix enabled: `test-login-ids/`
- Shorter retention: 365 days
- For integration testing

### Production (`prod`)
- Bucket: `abode-flinks`
- Test prefix disabled
- Long retention: 2555 days (7 years)
- For production data

## Security Features

- ✅ **No static credentials**: Cross-account IAM role with AssumeRole
- ✅ **External ID**: Prevents confused deputy attacks
- ✅ **Least privilege**: Only PutObject/ListBucket on specific prefix
- ✅ **Encryption**: SSE-S3 (AES256) by default
- ✅ **Versioning**: Enabled for data protection
- ✅ **Public access blocked**: All public access disabled
- ✅ **Bucket owner preferred**: All objects owned by bucket owner

## Cost Optimization

- **Lifecycle rules**: Automatically transition to Glacier after 90 days
- **Retention policy**: Automatically delete after 7 years (prod) / 1 year (dev)
- **Incomplete multipart upload cleanup**: Auto-abort after 7 days

## Validation

After vendor uploads test files:

```bash
# List files
aws s3 ls s3://abode-flinks-dev/login-ids/dataset=login-ids/dt=2025-10-14/

# Check encryption
aws s3api head-object \
  --bucket abode-flinks-dev \
  --key login-ids/dataset=login-ids/dt=2025-10-14/login-ids_20251014_part-0001.csv.gz

# Expected: ServerSideEncryption: AES256
```

## Maintenance

### Updating Terraform

```bash
cd terraform/environments/prod  # or dev
terraform plan
terraform apply
```

### Rotating External ID

1. Generate new External ID
2. Update `terraform.tfvars`
3. Apply changes: `terraform apply`
4. Share new External ID with vendor
5. Vendor updates their AssumeRole configuration

### Adding New Vendor

Duplicate the module call in `main.tf` with a different prefix/role name.

## Troubleshooting

### Vendor cannot assume role
- Verify External ID matches
- Confirm vendor's AWS Account ID is correct
- Check role trust policy

### Upload fails with Access Denied
- Confirm vendor is using SSE-S3: `--sse AES256`
- Verify file path matches allowed prefix: `login-ids/*`
- Check role session hasn't expired (max 1 hour by default)

### Files not appearing
- Check bucket region matches
- Verify correct prefix: `login-ids/`
- Ensure using correct AWS credentials

## Support

For issues or questions:
- **Infrastructure**: [Your Team Email]
- **Vendor Integration**: [Integration Team Email]
- **Documentation**: See `terraform/modules/s3-cross-account-ingestion/README.md`

## License

Internal use only.
