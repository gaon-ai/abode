# Infrastructure Documentation

## Troubleshooting

### Airflow 3.x Migration Issues

Airflow 3.1.3 has breaking changes from 2.x. If migrating DAGs:

**1. Schedule parameter renamed:**
```python
# ❌ Airflow 2.x (will error)
schedule_interval=timedelta(days=1)

# ✅ Airflow 3.x
schedule=timedelta(days=1)
```

**2. Import paths changed:**
```python
# ❌ Deprecated
from airflow.operators.bash import BashOperator

# ✅ New standard
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator
```

**3. Webserver command removed:**
```yaml
# ❌ Old command
command: webserver

# ✅ New command
command: api-server
```

**4. FAB auth manager required:**
Add to docker-compose.yaml environment:
```yaml
AIRFLOW__CORE__AUTH_MANAGER: airflow.providers.fab.auth_manager.fab_auth_manager.FabAuthManager
_PIP_ADDITIONAL_REQUIREMENTS: apache-airflow-providers-fab
```

### DAG Deployment Issues

**Problem: DAGs not appearing after deployment**

Airflow 3.x doesn't auto-parse DAGs. You must trigger parsing:
```bash
ssh -i ~/.ssh/airflow-dev.pem ubuntu@<instance-ip>
sudo docker compose -f /opt/airflow/docker-compose.yaml exec -T scheduler airflow dags reserialize
```

This is automated in the GitHub Actions workflow.

**Problem: Deleted DAG files still showing in UI**

Airflow keeps DAG metadata in database even when files are deleted.

Manual cleanup:
```bash
# List all DAGs
airflow dags list

# Delete specific DAG
airflow dags delete <dag_id> -y
```

Automated cleanup is included in GitHub Actions workflow.

**Problem: Permission denied errors during deployment**

DAG files must be owned by Airflow container user (uid 50000):
```bash
sudo chown -R 50000:0 /opt/airflow/dags/
sudo chmod -R 755 /opt/airflow/dags/
```

The GitHub Actions workflow handles this automatically with two-step deployment:
1. Deploy to `/tmp/airflow-dags/` (user writable)
2. Move with sudo and fix ownership

### DAG Execution Issues

**Problem: Tasks fail with "Permission denied" on logs**

```
PermissionError: [Errno 13] Permission denied: '/opt/airflow/logs/...'
```

Fix permissions:
```bash
ssh -i ~/.ssh/airflow-dev.pem ubuntu@<instance-ip>
sudo chown -R 50000:0 /opt/airflow/logs/
sudo chmod -R 755 /opt/airflow/logs/
```

**Problem: Connection refused errors**

Restart scheduler if DAGs fail with connection errors:
```bash
sudo docker compose -f /opt/airflow/docker-compose.yaml restart scheduler
```

### GitHub Actions Setup

**Required secrets** (Settings → Secrets → Actions):

1. `AIRFLOW_SSH_KEY` - Base64 encoded SSH private key:
   ```bash
   cat ~/.ssh/airflow-dev.pem | base64 | pbcopy
   ```

2. `AIRFLOW_HOST` - EC2 instance IP:
   ```bash
   terraform output airflow_url
   # Copy IP without http://
   ```

**Local testing with act:**

Install act:
```bash
brew install act
```

Create `.secrets` file (DON'T commit):
```bash
AIRFLOW_HOST=<your-instance-ip>
AIRFLOW_SSH_KEY=$(cat ~/.ssh/airflow-dev.pem | base64)
```

Test workflow:
```bash
act workflow_dispatch -W .github/workflows/deploy-dags.yml --secret-file .secrets
```

### Manual Operations

**Test DAG locally:**
```bash
ssh -i ~/.ssh/airflow-dev.pem ubuntu@<instance-ip>
sudo docker compose -f /opt/airflow/docker-compose.yaml exec scheduler airflow dags test <dag_id>
```

**View scheduler logs:**
```bash
sudo docker compose -f /opt/airflow/docker-compose.yaml logs scheduler -f
```

**Manually deploy DAG:**
```bash
# Copy to temp directory
scp -i ~/.ssh/airflow-dev.pem my_dag.py ubuntu@<instance-ip>:/tmp/

# Move with correct permissions
ssh -i ~/.ssh/airflow-dev.pem ubuntu@<instance-ip>
sudo mv /tmp/my_dag.py /opt/airflow/dags/
sudo chown 50000:0 /opt/airflow/dags/my_dag.py
sudo docker compose -f /opt/airflow/docker-compose.yaml exec -T scheduler airflow dags reserialize
```

**Check Airflow version:**
```bash
sudo docker compose exec scheduler airflow version
```

**List all DAGs with status:**
```bash
sudo docker compose exec scheduler airflow dags list --output table
```

## Resources

- [Apache Airflow Docs](https://airflow.apache.org/docs/apache-airflow/3.1.3/)
- [Airflow 3.0 Migration Guide](https://airflow.apache.org/docs/apache-airflow/3.1.3/migration-guide-to-3.html)
- [Docker Compose Reference](https://docs.docker.com/compose/)
