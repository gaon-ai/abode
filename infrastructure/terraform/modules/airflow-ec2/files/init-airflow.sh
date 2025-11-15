#!/bin/bash
set -e

cd /opt/airflow

# Initialize database
docker compose run --rm webserver airflow db migrate

# Wait for FAB provider to be installed
sleep 10

# Create admin user (requires FAB provider)
docker compose run --rm webserver airflow fab create-admin \
  --username admin \
  --password admin \
  --firstname Admin \
  --lastname User \
  --email admin@example.com || echo "User creation skipped - will use default login"

echo "Airflow initialized!"
