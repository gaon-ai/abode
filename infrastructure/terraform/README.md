# AWS MWAA Terraform

Terraform configuration for AWS Managed Workflows for Apache Airflow (MWAA).

## Structure

```
terraform/
├── modules/mwaa/           # Reusable MWAA module
├── environments/
│   ├── dev/               # Dev environment
│   └── prod/              # Prod environment
└── *.md                   # Documentation
```

## Quick Start

```bash
cd infrastructure/terraform
./setup-credentials.sh
vim .env  # Add AWS credentials
source .env

cd environments/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform apply
```

See `QUICKSTART.md` for detailed steps.

## What Gets Created

- VPC with public/private subnets and NAT gateway
- MWAA environment with auto-scaling workers
- S3 bucket for DAGs, requirements, plugins
- IAM roles with least-privilege permissions
- Security groups
- CloudWatch logging

## Environment Differences

| Setting | Dev | Prod |
|---------|-----|------|
| Instance | mw1.small | mw1.medium |
| Max Workers | 5 | 25 |
| Web Access | PUBLIC_ONLY | PRIVATE_ONLY |
| AZs | 2 | 3 |

## Usage

### Upload DAGs
```bash
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 cp my_dag.py s3://${S3_BUCKET}/dags/
```

### Add Python Packages
```bash
aws s3 cp requirements.txt s3://${S3_BUCKET}/requirements.txt
```

### Access Web UI
```bash
terraform output mwaa_webserver_url
```

## Configuration

Edit `terraform.tfvars`:
- `aws_region`: AWS region
- `environment_class`: Instance size (mw1.small, mw1.medium, etc.)
- `max_workers`: Maximum worker count
- `webserver_access_mode`: PUBLIC_ONLY or PRIVATE_ONLY
- `airflow_configuration_options`: Airflow config overrides

See `terraform.tfvars.example` for all options.

## Cost Estimate

- Dev (mw1.small): ~$400-600/month
- Prod (mw1.medium): ~$800-1,200/month

Run `terraform destroy` when not in use.

## Troubleshooting

- **No credentials**: `source .env` or `aws configure`
- **State lock**: Wait or force unlock
- **Can't access UI**: Check webserver_access_mode, wait 20-30min for MWAA
- **DAGs missing**: Wait 1-2min, check CloudWatch logs

## Docs

- `QUICKSTART.md` - Fast deployment steps
- `DEPLOYMENT.md` - Detailed guide with troubleshooting
- [AWS MWAA Docs](https://docs.aws.amazon.com/mwaa/latest/userguide/)
