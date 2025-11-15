# Abode - Self-Hosted Apache Airflow on EC2

Ultra-minimal, cost-optimized Apache Airflow deployment on AWS EC2.

## Cost

**~$26/month** (t4g.medium on-demand)
- EC2 t4g.medium: ~$24/month
- EBS 20GB gp3: ~$2/month

96% cheaper than AWS MWAA (~$480/month)

## Architecture

- **Apache Airflow 3.1.3** (latest)
- **LocalExecutor** (single-node, multi-threaded)
- **PostgreSQL 14** (database)
- **Docker Compose** (deployment)
- **t4g.medium** (ARM-based EC2, 2 vCPU, 4GB RAM)

## Quick Start

### 1. Setup AWS Credentials

```bash
cd infrastructure/terraform
./setup-credentials.sh
vim .env  # Add your AWS credentials
source .env
```

### 2. Create SSH Key (if needed)

```bash
aws ec2 create-key-pair --key-name airflow-key \
  --query 'KeyMaterial' --output text > ~/.ssh/airflow-key.pem
chmod 400 ~/.ssh/airflow-key.pem
```

### 3. Configure Terraform

```bash
cd environments/dev
cp terraform.tfvars.example terraform.tfvars
vim terraform.tfvars  # Set ssh_key_name
```

### 4. Deploy

```bash
terraform init
terraform plan
terraform apply
```

Wait ~5 minutes for initialization.

### 5. Access Airflow

```bash
# Get outputs
terraform output airflow_url
terraform output ssh_command

# Default credentials
Username: admin
Password: admin
```

## Deploy DAGs

### Via SCP

```bash
scp -i ~/.ssh/airflow-key.pem my_dag.py ubuntu@<instance-ip>:/opt/airflow/dags/
```

### Via SSH

```bash
ssh -i ~/.ssh/airflow-key.pem ubuntu@<instance-ip>
cd /opt/airflow/dags
vim my_dag.py
```

## Local Development

Test DAGs locally with Docker Compose:

```bash
cd airflow
cp .env.example .env
docker compose up airflow-init
docker compose up
```

Access at http://localhost:8080

## Structure

```
.
├── airflow/                       # Docker Compose config
│   ├── docker-compose.yaml        # Airflow services
│   ├── dags/                      # DAG files
│   ├── logs/                      # Airflow logs
│   └── plugins/                   # Custom plugins
└── infrastructure/terraform/
    ├── modules/airflow-ec2/       # EC2 module
    └── environments/dev/          # Dev environment
```

## Costs Breakdown

| Resource | Monthly Cost |
|----------|--------------|
| t4g.medium (on-demand) | ~$24 |
| EBS 20GB gp3 | ~$2 |
| **Total** | **~$26** |

**Savings options:**
- Reserved Instance (1yr): ~$16/month (42% off)
- Reserved Instance (3yr): ~$12/month (58% off)

## Security

**Before production:**
- Change admin password in Airflow UI
- Restrict security group IPs in `terraform.tfvars`
- Use HTTPS with nginx reverse proxy
- Rotate AWS credentials if exposed
- Set up backups for PostgreSQL + DAGs

## Cleanup

```bash
cd infrastructure/terraform/environments/dev
terraform destroy
```

## Support

- [Apache Airflow Docs](https://airflow.apache.org/docs/apache-airflow/3.1.3/)
- [Docker Compose Reference](https://docs.docker.com/compose/)
