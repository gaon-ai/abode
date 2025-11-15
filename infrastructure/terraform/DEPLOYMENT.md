# AWS MWAA Deployment Guide

Step-by-step instructions to deploy AWS Managed Airflow using Terraform with your admin IAM user credentials.

## Prerequisites

1. AWS Admin IAM user credentials (Access Key ID and Secret Access Key)
2. Terraform installed (>= 1.0)
3. AWS CLI installed

## Step 1: Configure AWS Credentials

You have three options for configuring AWS credentials:

### Option A: Using Local .env File (Recommended for this project)

We've set up a local `.env` file system that's already in `.gitignore`:

```bash
# From the repository root
cd infrastructure/terraform

# Run the setup script
./setup-credentials.sh

# Edit the .env file with your actual credentials
vim .env  # or use your preferred editor

# Load the credentials
source .env
```

Your `.env` file should look like:
```bash
export AWS_ACCESS_KEY_ID="AKIAXXXXXXXXXXXXXXXX"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Benefits**:
- Credentials persist locally (no need to set every time)
- Automatically excluded from git
- Works across all terminal sessions when sourced
- Easy to switch between different AWS accounts

### Option B: Using AWS CLI (System-wide)

```bash
aws configure
```

When prompted, enter:
- **AWS Access Key ID**: Your IAM user access key
- **AWS Secret Access Key**: Your IAM user secret key
- **Default region name**: `us-east-1` (or your preferred region)
- **Default output format**: `json`

This will create files at:
- `~/.aws/credentials` (contains your keys)
- `~/.aws/config` (contains region and output settings)

**Benefits**:
- Works system-wide for all AWS CLI commands
- No need to source before each session
- Industry standard approach

### Option C: Using Environment Variables (Per-session)

Set environment variables directly in your terminal:

```bash
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
```

**Note**: These only last for the current terminal session.

**IMPORTANT**: Never commit AWS credentials to git. The `.env` file is already in `.gitignore`.

## Step 2: Verify AWS Access

Test that your credentials work:

```bash
aws sts get-caller-identity
```

You should see output with your AWS account ID and user ARN.

## Step 3: Navigate to Environment Directory

For development environment:
```bash
cd infrastructure/terraform/environments/dev
```

For production environment:
```bash
cd infrastructure/terraform/environments/prod
```

## Step 4: Configure Terraform Variables

Copy the example variables file:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your settings:

```bash
# Open with your preferred editor
vim terraform.tfvars
# or
code terraform.tfvars
```

**Minimum required changes**:
```hcl
# AWS Configuration
aws_region = "us-east-1"  # Change to your preferred region
project_name = "abode"
environment = "dev"

# Keep other defaults or customize as needed
```

**Important variables to review**:

- `vpc_cidr`: Ensure it doesn't conflict with existing VPCs
- `availability_zones`: Must match your AWS region
- `environment_class`: Start with `mw1.small` for dev
- `webserver_access_mode`: Use `PUBLIC_ONLY` for easier access during testing

## Step 5: Initialize Terraform

Initialize Terraform to download required providers and modules:

```bash
terraform init
```

Expected output:
```
Initializing modules...
Initializing the backend...
Initializing provider plugins...
Terraform has been successfully initialized!
```

## Step 6: Review Deployment Plan

Preview what Terraform will create:

```bash
terraform plan
```

Review the output carefully. You should see resources being created for:
- VPC and networking (subnets, NAT gateway, route tables)
- S3 bucket for Airflow DAGs
- IAM roles and policies
- Security groups
- MWAA environment

## Step 7: Deploy Infrastructure

Apply the Terraform configuration:

```bash
terraform apply
```

When prompted with "Do you want to perform these actions?", type `yes` and press Enter.

**Deployment time**: 20-30 minutes for MWAA environment to be fully ready.

## Step 8: Verify Deployment

Once complete, Terraform will show outputs:

```bash
Apply complete! Resources: X added, 0 changed, 0 destroyed.

Outputs:

mwaa_webserver_url = "https://xxxxx.airflow.us-east-1.amazonaws.com"
s3_bucket_name = "abode-dev-mwaa-dev"
mwaa_execution_role_arn = "arn:aws:iam::xxxxx:role/abode-dev-mwaa-execution-role-dev"
```

Save these outputs - you'll need them!

## Step 9: Access Airflow Web UI

Get the webserver URL:

```bash
terraform output mwaa_webserver_url
```

Open this URL in your browser. You'll need to authenticate with AWS credentials.

## Step 10: Upload Your First DAG

Create a simple test DAG file (`hello_world_dag.py`):

```python
from datetime import datetime, timedelta
from airflow import DAG
from airflow.operators.python import PythonOperator

def print_hello():
    return 'Hello from MWAA!'

default_args = {
    'owner': 'airflow',
    'depends_on_past': False,
    'start_date': datetime(2024, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5),
}

dag = DAG(
    'hello_world',
    default_args=default_args,
    description='A simple hello world DAG',
    schedule_interval=timedelta(days=1),
    catchup=False,
)

hello_task = PythonOperator(
    task_id='print_hello',
    python_callable=print_hello,
    dag=dag,
)
```

Upload it to S3:

```bash
# Get bucket name
S3_BUCKET=$(terraform output -raw s3_bucket_name)

# Upload DAG
aws s3 cp hello_world_dag.py s3://${S3_BUCKET}/dags/
```

Wait 1-2 minutes, then check the Airflow UI - your DAG should appear!

## Troubleshooting

### Issue: "Error acquiring the state lock"

**Solution**: Someone else or another process is running Terraform. Wait and try again, or break the lock if you're sure no one else is using it.

### Issue: "Insufficient permissions"

**Solution**: Verify your IAM user has admin permissions:
```bash
aws iam get-user
aws iam list-attached-user-policies --user-name YOUR_USERNAME
```

### Issue: "Availability zone not available"

**Solution**: Update `availability_zones` in your `terraform.tfvars` to use AZs available in your region:
```bash
aws ec2 describe-availability-zones --region us-east-1 --query 'AvailabilityZones[].ZoneName'
```

### Issue: MWAA environment stuck in "Creating"

**Solution**: Check CloudWatch logs:
```bash
aws logs tail airflow-abode-dev-DAGProcessing --follow
```

### Issue: Can't access Airflow UI

For `PUBLIC_ONLY` mode:
- Check if your IP is allowed in any network ACLs
- Verify you're logged into AWS in your browser
- Try accessing from AWS Console > MWAA > Environments > Open Airflow UI

For `PRIVATE_ONLY` mode:
- You need VPN or AWS Direct Connect
- Or change to `PUBLIC_ONLY` in terraform.tfvars and re-apply

## Managing Python Dependencies

Create `requirements.txt`:

```txt
apache-airflow-providers-amazon==8.0.0
pandas==2.0.0
requests==2.31.0
```

Upload to S3:

```bash
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 cp requirements.txt s3://${S3_BUCKET}/requirements.txt
```

MWAA will automatically detect and install these packages (takes 10-15 minutes).

## Cost Management

### Development Environment (mw1.small)
- Base cost: ~$0.49/hour (~$380/month)
- Plus worker hours: ~$0.12/hour per worker
- Estimated monthly: $400-600

### To Minimize Costs
- Destroy when not in use: `terraform destroy`
- Use smaller environment class
- Reduce max_workers
- Monitor costs in AWS Cost Explorer

## Updating the Infrastructure

After making changes to `terraform.tfvars`:

```bash
terraform plan    # Review changes
terraform apply   # Apply changes
```

## Destroying Infrastructure

When you're done and want to clean up everything:

```bash
terraform destroy
```

Type `yes` when prompted. This will:
- Delete the MWAA environment
- Delete the VPC and networking
- Delete the S3 bucket (must be empty first)

**Before destroying**, back up any important DAGs:
```bash
S3_BUCKET=$(terraform output -raw s3_bucket_name)
aws s3 sync s3://${S3_BUCKET}/dags/ ./backup/dags/
```

## Next Steps

1. Create more DAGs and upload to S3
2. Configure Airflow connections in the UI
3. Set up monitoring with CloudWatch
4. Configure backend state storage in S3 (see main.tf comments)
5. Set up CI/CD for automated DAG deployments

## Security Best Practices

1. **Never commit credentials**: Keep `.env` in `.gitignore`
2. **Use IAM roles**: For production, use IAM roles instead of access keys
3. **Enable MFA**: Enable multi-factor authentication on your IAM user
4. **Rotate keys**: Regularly rotate your access keys
5. **Use PRIVATE_ONLY**: For production, use `PRIVATE_ONLY` webserver access mode
6. **Review IAM policies**: Use least-privilege IAM policies for MWAA execution role
7. **Enable encryption**: Use KMS encryption for S3 (via `kms_key_arn` variable)

## Support Resources

- [AWS MWAA Documentation](https://docs.aws.amazon.com/mwaa/latest/userguide/)
- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- Check CloudWatch Logs for debugging

## Common Terraform Commands

```bash
# Initialize
terraform init

# Format code
terraform fmt

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Show current state
terraform show

# List outputs
terraform output

# Destroy everything
terraform destroy

# Refresh state
terraform refresh

# Import existing resource
terraform import <resource_type>.<resource_name> <resource_id>
```
