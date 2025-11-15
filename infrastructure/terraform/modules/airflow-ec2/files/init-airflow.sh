#!/bin/bash
set -e

cd /opt/airflow

# Set permissions
chown -R 50000:0 /opt/airflow/{dags,logs,plugins,config}

# Initialize Airflow database
docker compose run --rm airflow-webserver airflow db migrate

# Create admin user
docker compose run --rm airflow-webserver airflow users create \
  --username admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com \
  --password admin

echo "Airflow initialization complete!"
