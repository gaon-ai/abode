# Quick Start

## Setup

```bash
cd infrastructure/terraform
./setup-credentials.sh
vim .env  # Add AWS Access Key ID and Secret
source .env
```

## Deploy

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform plan
terraform apply  # Takes 20-30 minutes
```

## Use

```bash
# Get Airflow URL
terraform output mwaa_webserver_url

# Upload DAG
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 cp your_dag.py s3://${S3_BUCKET}/dags/
```

## Cleanup

```bash
terraform destroy
```

## Notes

- Load credentials each session: `source ../../.env`
- Cost: ~$400-600/month for dev
- See `DEPLOYMENT.md` for troubleshooting
