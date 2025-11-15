# Deployment Guide

## Prerequisites

- AWS Admin IAM credentials
- Terraform >= 1.0
- AWS CLI

## 1. Configure Credentials

### Option A: Local .env (Recommended)

```bash
cd infrastructure/terraform
./setup-credentials.sh
vim .env  # Add your credentials
source .env
```

### Option B: AWS CLI

```bash
aws configure  # Enter credentials when prompted
```

## 2. Verify Access

```bash
aws sts get-caller-identity
```

## 3. Configure Variables

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Edit if needed
```

## 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

Deployment takes 20-30 minutes.

## 5. Access Airflow

```bash
terraform output mwaa_webserver_url
```

## 6. Upload DAG

```bash
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 cp hello_world.py s3://${S3_BUCKET}/dags/
```

## Troubleshooting

### No credentials
```bash
source ../../.env
```

### Can't access UI
- Wait 20-30 minutes for MWAA to be ready
- Verify `webserver_access_mode = "PUBLIC_ONLY"` in terraform.tfvars
- Log into AWS in browser first

### DAGs not showing
- Wait 1-2 minutes after upload
- Check CloudWatch: `aws logs tail airflow-abode-dev-DAGProcessing --follow`

### State lock error
Another terraform process is running. Wait or break lock.

## Managing Dependencies

Create `requirements.txt`:
```txt
apache-airflow-providers-amazon
pandas==2.0.0
```

Upload:
```bash
aws s3 cp requirements.txt s3://${S3_BUCKET}/requirements.txt
```

## Cleanup

```bash
terraform destroy
```

## Security

- Never commit `.env` (already in .gitignore)
- Rotate AWS keys if exposed
- Use PRIVATE_ONLY for production webserver access

## Cost

- Dev: ~$400-600/month
- Prod: ~$800-1,200/month
- Destroy when not in use

## Common Commands

```bash
terraform output                    # List all outputs
terraform show                      # Show current state
terraform refresh                   # Sync state with AWS
terraform fmt                       # Format code
terraform validate                  # Validate config
```
