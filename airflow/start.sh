#!/bin/bash

# Start Airflow locally using Docker Compose (Standalone Mode)
# This script starts Airflow in standalone mode for local development

set -e

echo "🚀 Starting Airflow in standalone mode..."

# Set AIRFLOW_UID for proper file permissions
export AIRFLOW_UID=$(id -u)

# Create necessary directories if they don't exist
mkdir -p dags logs plugins config

# Start Airflow services
echo "✅ Starting Airflow..."
docker compose up -d

# Wait for services to start
echo "⏳ Waiting for Airflow to initialize..."
sleep 10

# Get the admin password from logs
PASSWORD=$(docker compose logs airflow-standalone 2>&1 | grep "Password for user 'admin':" | awk -F': ' '{print $2}' | tail -1)

echo ""
echo "✨ Airflow is ready!"
echo "🌐 Web UI: http://localhost:8081"
echo "👤 Login credentials:"
echo "   Username: admin"
if [ -n "$PASSWORD" ]; then
    echo "   Password: $PASSWORD"
else
    echo "   Password: Check logs with 'docker compose logs airflow-standalone | grep Password'"
fi
echo ""
echo "📊 To view logs: docker compose logs -f"
echo "🛑 To stop: ./stop.sh or docker compose down"
