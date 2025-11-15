# Managing Secrets in Airflow

## Methods for Managing Secrets

### 1. Airflow Connections (Built-in)

**Best for:** Database connections, API keys

Store in Airflow UI or via CLI:

```bash
# Via SSH to EC2
ssh -i ~/.ssh/airflow-key.pem ubuntu@<instance-ip>

# Create connection
docker compose exec webserver airflow connections add \
  'my_postgres_conn' \
  --conn-type 'postgres' \
  --conn-host 'my-rds.xxxx.us-east-1.rds.amazonaws.com' \
  --conn-login 'dbuser' \
  --conn-password 'dbpassword' \
  --conn-port '5432' \
  --conn-schema 'mydb'
```

**In DAG:**
```python
from airflow.hooks.postgres_hook import PostgresHook

hook = PostgresHook(postgres_conn_id='my_postgres_conn')
conn = hook.get_conn()
```

**Via UI:**
- Go to http://<instance-ip>:8080
- Admin → Connections → Add
- Fill in connection details

---

### 2. AWS Secrets Manager (Recommended for Production)

**Best for:** Production secrets, automatic rotation

#### Setup

**a) Add IAM permissions to EC2:**

```hcl
# In infrastructure/terraform/modules/airflow-ec2/main.tf

resource "aws_iam_role" "airflow" {
  name = "${var.project_name}-airflow-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "secrets" {
  role = aws_iam_role.airflow.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "secretsmanager:GetSecretValue"
      ]
      Resource = "arn:aws:secretsmanager:*:*:secret:airflow/*"
    }]
  })
}

resource "aws_iam_instance_profile" "airflow" {
  name = "${var.project_name}-airflow-${var.environment}"
  role = aws_iam_role.airflow.name
}

# Add to EC2 instance
resource "aws_instance" "airflow" {
  # ... existing config ...
  iam_instance_profile = aws_iam_instance_profile.airflow.name
}
```

**b) Install AWS provider in Airflow:**

```bash
# SSH to EC2
ssh -i ~/.ssh/airflow-key.pem ubuntu@<instance-ip>

# Add to docker-compose.yaml
# Add this pip install to init or use requirements.txt
docker compose exec webserver pip install apache-airflow-providers-amazon
```

**c) Configure Airflow to use Secrets Manager:**

Add to docker-compose.yaml environment:
```yaml
AIRFLOW__SECRETS__BACKEND: airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend
AIRFLOW__SECRETS__BACKEND_KWARGS: '{"connections_prefix": "airflow/connections", "variables_prefix": "airflow/variables"}'
```

**d) Store secrets in AWS:**

```bash
# Store connection
aws secretsmanager create-secret \
  --name airflow/connections/my_rds \
  --secret-string '{
    "conn_type": "postgres",
    "host": "my-rds.xxxx.us-east-1.rds.amazonaws.com",
    "login": "dbuser",
    "password": "dbpassword",
    "port": 5432,
    "schema": "mydb"
  }'

# Store variable
aws secretsmanager create-secret \
  --name airflow/variables/api_key \
  --secret-string "my-secret-api-key"
```

**In DAG:**
```python
# Connection works the same
hook = PostgresHook(postgres_conn_id='my_rds')

# Variables
from airflow.models import Variable
api_key = Variable.get("api_key")
```

---

### 3. Environment Variables

**Best for:** Non-sensitive config, simple setup

**Add to docker-compose.yaml:**
```yaml
services:
  webserver:
    environment:
      MY_API_URL: "https://api.example.com"
      # For secrets (less secure):
      MY_API_KEY: "secret-key"
```

**In DAG:**
```python
import os
api_key = os.getenv('MY_API_KEY')
```

---

### 4. Encrypted Variables (Airflow Built-in)

**Best for:** Simple secrets without external dependencies

Airflow automatically encrypts Variables using Fernet key.

**Store secret:**
```bash
docker compose exec webserver airflow variables set \
  my_secret_key \
  "my-secret-value"
```

**In DAG:**
```python
from airflow.models import Variable
secret = Variable.get("my_secret_key")
```

---

## Comparison

| Method | Security | Complexity | Best For |
|--------|----------|------------|----------|
| Airflow Connections | Medium | Low | Dev, simple setups |
| AWS Secrets Manager | High | Medium | Production, compliance |
| Environment Variables | Low | Very Low | Non-secrets only |
| Airflow Variables | Medium | Low | Small secrets |

---

## Recommended Approach

### For Dev/Testing
Use **Airflow Connections** via UI - simple and fast

### For Production
Use **AWS Secrets Manager**:
1. Centralized secret management
2. Automatic rotation support
3. Audit logging
4. Fine-grained IAM permissions
5. Shared across services

---

## Example: RDS Connection

### Quick (Dev)
```bash
# Via Airflow UI
Admin → Connections → Add
Connection Id: my_rds
Connection Type: Postgres
Host: my-db.xxxx.rds.amazonaws.com
Schema: mydb
Login: dbuser
Password: dbpass
Port: 5432
```

### Production (AWS Secrets Manager)

**1. Store in Secrets Manager:**
```bash
aws secretsmanager create-secret \
  --name airflow/connections/prod_rds \
  --secret-string '{
    "conn_type": "postgres",
    "host": "prod-db.xxxx.rds.amazonaws.com",
    "login": "dbuser",
    "password": "SECURE_PASSWORD",
    "port": 5432,
    "schema": "proddb"
  }'
```

**2. Configure Airflow (see setup above)**

**3. Use in DAG:**
```python
from airflow.hooks.postgres_hook import PostgresHook

def query_database():
    hook = PostgresHook(postgres_conn_id='prod_rds')
    result = hook.get_records("SELECT * FROM users LIMIT 10")
    return result
```

---

## Security Best Practices

1. **Never commit secrets to git**
2. **Use AWS Secrets Manager for production**
3. **Rotate secrets regularly**
4. **Use IAM roles instead of access keys**
5. **Restrict secret access via IAM policies**
6. **Enable audit logging**
7. **Use different secrets per environment**
