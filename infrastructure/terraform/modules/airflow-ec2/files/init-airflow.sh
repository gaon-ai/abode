#!/bin/bash
set -e

cd /opt/airflow

# Initialize database
docker compose run --rm webserver airflow db migrate

# Create admin user
docker compose run --rm webserver airflow users create \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --role Admin \
  --email admin@example.com

echo "Airflow initialized!"
