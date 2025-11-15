# Quick Start Guide

Fast setup for deploying AWS MWAA with Terraform.

## One-Time Setup

### 1. Set up AWS Credentials (Local .env file)

```bash
cd infrastructure/terraform
./setup-credentials.sh
vim .env  # Add your AWS credentials
source .env
```

Your `.env` file:
```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

### 2. Configure Terraform Variables

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars if needed (defaults are good for testing)
```

## Deploy

```bash
# Make sure credentials are loaded
source ../../.env  # if not already sourced

# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (takes 20-30 minutes)
terraform apply
```

## Access Airflow

```bash
# Get the web UI URL
terraform output mwaa_webserver_url

# Get S3 bucket name for uploading DAGs
terraform output s3_bucket_name
```

## Upload a DAG

```bash
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 cp your_dag.py s3://${S3_BUCKET}/dags/
```

## Destroy (Clean Up)

```bash
terraform destroy
```

## Every Time You Open a New Terminal

If using the local `.env` file approach, remember to load credentials:

```bash
cd infrastructure/terraform
source .env
cd environments/dev
# Now run terraform commands
```

## Quick Commands

```bash
# See current state
terraform show

# See all outputs
terraform output

# Refresh state
terraform refresh

# Format code
terraform fmt

# Validate configuration
terraform validate
```

## Troubleshooting

### "No valid credential sources found"
Load your credentials: `source ../../.env`

### "Error acquiring state lock"
Someone else is running terraform, or previous run didn't complete. Wait or break lock.

### Can't access Airflow UI
- Verify webserver_access_mode is "PUBLIC_ONLY" in terraform.tfvars
- Check you're logged into AWS in your browser
- MWAA takes 20-30 minutes to be fully ready

### DAGs not appearing
- Wait 1-2 minutes after uploading
- Check DAG syntax (no Python errors)
- Check CloudWatch logs: `aws logs tail airflow-abode-dev-DAGProcessing --follow`

## Cost Alert

Development environment costs ~$400-600/month. Remember to `terraform destroy` when not in use!

## Need More Help?

See detailed guides:
- `DEPLOYMENT.md` - Full step-by-step deployment guide
- `README.md` - Technical reference and configuration options
