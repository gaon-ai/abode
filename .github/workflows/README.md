# GitHub Actions Workflows

## Setup Instructions

### Required Secrets

To enable the DAG deployment workflow, you need to configure two GitHub secrets:

**Steps:**
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add the following two secrets:

#### 1. `AIRFLOW_SSH_KEY`

Your SSH private key, base64 encoded.

**Generate the value:**
```bash
# First, get your EC2 instance IP
cd infrastructure/terraform/environments/dev
terraform output airflow_url
# Note the IP address

# Encode your SSH key
cat ~/.ssh/airflow-dev.pem | base64 | pbcopy
```

**In GitHub:**
- Secret name: `AIRFLOW_SSH_KEY`
- Secret value: Paste the base64-encoded key from clipboard

#### 2. `AIRFLOW_HOST`

Your EC2 instance's public IP address (without http:// or port).

**Get the value:**
```bash
# Get the IP from terraform output
terraform output airflow_url
# Example output: http://15.223.29.50:8080

# Use just the IP address: 15.223.29.50
```

**In GitHub:**
- Secret name: `AIRFLOW_HOST`
- Secret value: Just the IP (e.g., `15.223.29.50`)

### Verify Setup

Once secrets are configured, the workflow will automatically run when:

1. **Automatic trigger:** Push changes to `main` branch that modify files in `airflow/dags/**`
2. **Manual trigger:** Go to Actions tab → Deploy DAGs to Airflow → Run workflow

### Test the Workflow

After adding secrets, test the deployment:

```bash
# Make a small change to a DAG
echo "# Updated $(date)" >> airflow/dags/hello_world.py

# Commit and push
git add airflow/dags/hello_world.py
git commit -m "Test workflow deployment"
git push origin main
```

Then check the **Actions** tab in GitHub to see the workflow run.

## Workflows

### `deploy-dags.yml`

Automatically deploys DAG files to the Airflow EC2 instance.

**What it does:**
- ✅ Deploys DAG files to `/opt/airflow/dags/` with correct permissions (50000:0)
- ✅ Triggers DAG parsing with `airflow dags reserialize`
- ✅ Cleans up orphaned DAGs (deleted from files but still in database)
- ✅ Verifies deployment by listing deployed files

**Triggers:**
- Push to `main` branch with changes in `airflow/dags/**`
- Manual workflow dispatch

**Duration:** ~30-60 seconds

## Local Testing

You can test the workflow locally using `act`:

### Install act

```bash
brew install act
```

### Create `.secrets` file

Create a `.secrets` file in the project root (DON'T commit this):

```bash
AIRFLOW_HOST=<your-instance-ip>
AIRFLOW_SSH_KEY=$(cat ~/.ssh/airflow-dev.pem | base64)
```

### Run the workflow

```bash
act workflow_dispatch -W .github/workflows/deploy-dags.yml --secret-file .secrets
```

This runs the workflow locally using Docker, allowing you to test changes before pushing to GitHub.

## Troubleshooting

**Workflow fails with "Host key verification failed"**
- The workflow automatically adds the host to known_hosts, but if it fails, check that `AIRFLOW_HOST` is correct

**Workflow fails with "Permission denied (publickey)"**
- Verify `AIRFLOW_SSH_KEY` is base64 encoded correctly
- Check that the SSH key has access to the EC2 instance

**DAGs not appearing after successful deployment**
- The workflow triggers `airflow dags reserialize` automatically
- Wait 30-60 seconds and refresh the Airflow UI
- Check scheduler logs: `sudo docker compose logs scheduler -f`

**Orphaned DAGs not deleted**
- The cleanup logic checks for `<dag_id>.py` files in the dags directory
- If your DAG files have different naming, adjust the cleanup script in the workflow

For more troubleshooting, see [infrastructure/README.md](../../infrastructure/README.md).
