#!/bin/bash

# Stop Airflow services

set -e

echo "🛑 Stopping Airflow..."

docker compose down

echo "✅ Airflow stopped successfully!"
echo ""
echo "💡 To start again: ./start.sh"
echo "🗑️  To remove all data (volumes): docker compose down -v"
