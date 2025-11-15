#!/bin/bash

# Start Airflow locally using Docker Compose
# This script initializes and starts all Airflow services

set -e

echo "🚀 Starting Airflow..."

# Set AIRFLOW_UID for proper file permissions
export AIRFLOW_UID=$(id -u)

# Create necessary directories if they don't exist
mkdir -p dags logs plugins config

# Initialize Airflow (first time setup)
echo "📦 Initializing Airflow database and creating admin user..."
docker compose up airflow-init

# Start Airflow services
echo "✅ Starting Airflow webserver and scheduler..."
docker compose up -d

echo ""
echo "✨ Airflow is starting up!"
echo "🌐 Web UI will be available at: http://localhost:8081"
echo "👤 Login credentials:"
echo "   Username: admin"
echo "   Password: admin"
echo ""
echo "📊 To view logs: docker compose logs -f"
echo "🛑 To stop: ./stop.sh or docker compose down"
