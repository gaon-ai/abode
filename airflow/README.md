# Airflow Local Development Setup

This directory contains a local Apache Airflow development environment using Docker Compose in **standalone mode**.

## Quick Start

```bash
cd airflow
./start.sh    # Start Airflow
./stop.sh     # Stop Airflow
```

## Directory Structure

```
airflow/
├── docker-compose.yaml          # Standalone Airflow configuration
├── start.sh                     # Start script (shows login credentials)
├── stop.sh                      # Stop script
├── requirements.txt             # Python dependencies for DAGs
├── dags/                        # DAG definitions go here
│   └── hello_world.py          # Example DAG
├── plugins/                     # Custom operators, hooks, sensors
│   ├── operators/
│   ├── hooks/
│   └── sensors/
├── include/                     # SQL files, configs, static files
│   └── sql/
├── tests/                       # Unit tests
│   └── dags/
├── logs/                        # Task execution logs
└── config/                      # Airflow configuration files
```

## Architecture: Standalone Mode

This setup uses **Airflow Standalone** mode, which runs all components in a single container:
- API Server (Web UI)
- Scheduler
- DAG Processor
- LocalExecutor

**Why Standalone?**
- ✅ Simpler setup for local development
- ✅ Fewer moving parts, easier to debug
- ✅ No inter-container communication issues
- ❌ Not for production use

## Login Credentials

After starting Airflow, the admin password is auto-generated and displayed by `start.sh`.

- **URL**: http://localhost:8081
- **Username**: `admin`
- **Password**: Shown by `start.sh` or run:
  ```bash
  docker compose logs airflow-standalone | grep "Password for user"
  ```

**Troubleshooting Login:**
- Clear browser cache/cookies for localhost:8081
- Try incognito/private mode
- Copy-paste the password (it's case-sensitive)

## Auto-Reload / Hot Reload

**Yes, Airflow automatically detects DAG file changes!**

This setup is configured for **fast local development**:
- **DAG folder scan**: Every 30 seconds (checks for new/deleted files)
- **File change detection**: Every 10 seconds (checks for modifications)

After editing a DAG file, changes will appear in the UI within ~30 seconds.

**What gets auto-reloaded:**
- ✅ DAG code changes (task modifications, schedule changes, etc.)
- ✅ New DAG files
- ✅ Deleted DAG files
- ✅ Plugin changes (may require restart for some changes)

**What doesn't auto-reload:**
- ❌ Environment variables in `docker-compose.yaml` (requires restart)
- ❌ Python package installations (requires restart)
- ❌ Airflow configuration changes (requires restart)

**Manual refresh:**
If you want to force an immediate refresh, restart the container:
```bash
docker compose restart airflow-standalone
```

## Creating DAGs

### Airflow 3.x Changes

This setup uses **Apache Airflow 3.1.3**. Key differences from 2.x:

1. **Operator Imports**: Use `airflow.providers.standard.operators`
   ```python
   # ✅ Airflow 3.x
   from airflow.providers.standard.operators.bash import BashOperator
   from airflow.providers.standard.operators.python import PythonOperator

   # ❌ Airflow 2.x (deprecated)
   from airflow.operators.bash import BashOperator
   from airflow.operators.python import PythonOperator
   ```

2. **DAG Schedule**: Use `schedule` instead of `schedule_interval`
   ```python
   # ✅ Airflow 3.x
   dag = DAG(
       'my_dag',
       schedule=timedelta(days=1),
       ...
   )

   # ❌ Airflow 2.x (removed)
   dag = DAG(
       'my_dag',
       schedule_interval=timedelta(days=1),
       ...
   )
   ```

3. **DAG Processor Required**: Airflow 3.x requires a separate DAG processor to parse DAG files (handled automatically in standalone mode)

### DAG Development Workflow

1. **Create your DAG file** in `dags/`
   ```bash
   touch dags/my_new_dag.py
   ```

2. **Test the DAG syntax**
   ```bash
   docker exec airflow-airflow-standalone-1 python /opt/airflow/dags/my_new_dag.py
   ```

3. **List all DAGs**
   ```bash
   docker exec airflow-airflow-standalone-1 airflow dags list
   ```

4. **Unpause the DAG** (DAGs are paused by default)
   ```bash
   docker exec airflow-airflow-standalone-1 airflow dags unpause my_new_dag
   ```

5. **Trigger manually**
   ```bash
   docker exec airflow-airflow-standalone-1 airflow dags trigger my_new_dag
   ```

## Common Commands

### Container Management
```bash
# Start Airflow
./start.sh

# Stop Airflow
./stop.sh

# View logs
docker compose logs -f

# View specific service logs
docker compose logs -f airflow-standalone

# Check container status
docker compose ps
```

### DAG Management
```bash
# List all DAGs
docker exec airflow-airflow-standalone-1 airflow dags list

# Trigger a DAG
docker exec airflow-airflow-standalone-1 airflow dags trigger <dag_id>

# Unpause a DAG
docker exec airflow-airflow-standalone-1 airflow dags unpause <dag_id>

# Pause a DAG
docker exec airflow-airflow-standalone-1 airflow dags pause <dag_id>

# Test a specific task
docker exec airflow-airflow-standalone-1 airflow tasks test <dag_id> <task_id> <execution_date>
```

### Debugging
```bash
# Check if DAG file has errors
docker exec airflow-airflow-standalone-1 python /opt/airflow/dags/<dag_file>.py

# View task logs
docker exec airflow-airflow-standalone-1 find /opt/airflow/logs -name "*.log" -path "*/<dag_id>/*" -exec cat {} \;

# Access Airflow shell
docker exec -it airflow-airflow-standalone-1 bash
```

## Troubleshooting

### Issue: DAGs not appearing in UI

**Symptoms**: DAG file exists but doesn't show in UI

**Solution**:
1. Check for syntax errors:
   ```bash
   docker exec airflow-airflow-standalone-1 python /opt/airflow/dags/my_dag.py
   ```
2. Check if DAG processor is running:
   ```bash
   docker compose logs airflow-standalone | grep dag-processor
   ```
3. Verify file is mounted:
   ```bash
   docker exec airflow-airflow-standalone-1 ls -la /opt/airflow/dags/
   ```

### Issue: Tasks failing with "Connection refused"

**Symptoms**: Tasks marked as "up for retry" with connection errors

**Root Cause**: Multi-container LocalExecutor setup has inter-container communication issues in Airflow 3.x

**Solution**: Use standalone mode (already configured in this setup)

### Issue: Import errors for BashOperator/PythonOperator

**Symptoms**: `ModuleNotFoundError` or deprecation warnings

**Solution**: Update imports to use `airflow.providers.standard.operators`:
```python
from airflow.providers.standard.operators.bash import BashOperator
from airflow.providers.standard.operators.python import PythonOperator
```

### Issue: "schedule_interval" not recognized

**Symptoms**: `TypeError: DAG.__init__() got an unexpected keyword argument 'schedule_interval'`

**Solution**: Use `schedule` instead:
```python
dag = DAG('my_dag', schedule=timedelta(days=1), ...)
```

### Issue: Port 8080 already in use

**Symptoms**: Docker error "port is already allocated"

**Solution**: This setup uses port 8081 instead. If 8081 is also in use, edit `docker-compose.yaml`:
```yaml
ports:
  - "8082:8080"  # Change 8081 to any available port
```

## Configuration Files

### docker-compose.yaml
- **Mode**: Standalone (single container)
- **Port**: 8081 → 8080 (container)
- **Database**: PostgreSQL 14
- **Executor**: LocalExecutor
- **Providers**: FAB (authentication), Standard (operators)

### requirements.txt
Add DAG-specific Python dependencies here. The container will install them on startup.

**Note**: Using `_PIP_ADDITIONAL_REQUIREMENTS` in docker-compose is for development only. For production, build a custom Docker image.

## Deployment vs Local Development

### Local (this setup)
- **Mode**: Standalone
- **Docker Compose**: `airflow/docker-compose.yaml`
- **Purpose**: Development and testing
- **Features**: Auto-initialization, healthchecks, full volume mounts

### Production (Terraform)
- **Location**: `infrastructure/terraform/modules/airflow-ec2/files/docker-compose.yaml`
- **Mode**: Multi-service (webserver, scheduler, postgres)
- **Purpose**: Production deployment on EC2
- **Differences**:
  - No auto-init
  - No plugins/config volumes
  - Minimal environment variables
  - Uses `webserver` command (not `api-server`)

**Important**: These are intentionally kept separate. Local dev uses latest features and conveniences. Production uses stable, minimal configuration.

## Best Practices

### DAG Development
1. **Keep DAG files simple**: Only DAG definitions in `dags/`
2. **Custom code in plugins**: Put operators/hooks/sensors in `plugins/`
3. **Static files in include**: SQL, configs, etc. go in `include/`
4. **Test before commit**: Always run `python dags/your_dag.py` first
5. **Use catchup=False**: Avoid backfilling during development

### File Organization
```python
# Good: Clear separation
dags/
  my_dag.py              # DAG definition only
plugins/
  operators/
    my_operator.py       # Custom operator
include/
  sql/
    my_query.sql         # SQL files

# Bad: Everything in DAG file
dags/
  my_dag.py              # DAG + operators + SQL = messy
```

### Testing
```bash
# Test DAG syntax
docker exec airflow-airflow-standalone-1 python /opt/airflow/dags/my_dag.py

# Test single task
docker exec airflow-airflow-standalone-1 airflow tasks test my_dag my_task 2024-01-01

# Trigger full DAG run
docker exec airflow-airflow-standalone-1 airflow dags trigger my_dag
```

## Resources

- [Airflow 3.x Documentation](https://airflow.apache.org/docs/apache-airflow/stable/)
- [Airflow Docker Documentation](https://airflow.apache.org/docs/docker-stack/index.html)
- [Airflow 3.x Migration Guide](https://airflow.apache.org/docs/apache-airflow/stable/installation/upgrading.html)
- [DAG Writing Best Practices](https://airflow.apache.org/docs/apache-airflow/stable/best-practices.html)

## Example DAG

See `dags/hello_world.py` for a working example with:
- BashOperator
- PythonOperator
- Task dependencies
- Proper Airflow 3.x syntax

## Support

For issues or questions:
1. Check this README first
2. Review container logs: `docker compose logs -f`
3. Check Airflow docs for version 3.x specific issues
4. Look at `docker-compose.yaml.backup` if you need the old multi-container setup
