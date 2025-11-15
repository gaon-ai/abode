#!/bin/bash
set -e

# Update and install Docker
apt-get update
apt-get install -y docker.io docker-compose-v2

# Start Docker
systemctl enable --now docker

# Setup Airflow
mkdir -p /opt/airflow/dags /opt/airflow/logs
cd /opt/airflow

# Write config files
cat > docker-compose.yaml <<'EOF'
${docker_compose}
EOF

cat > init-airflow.sh <<'EOF'
${init_script}
EOF
chmod +x init-airflow.sh

# Initialize and start
./init-airflow.sh
docker compose up -d

echo "Airflow ready at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Login: admin/admin"
