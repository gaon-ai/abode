#!/bin/bash
set -e

# Update system
apt-get update
apt-get upgrade -y

# Install Docker
apt-get install -y ca-certificates curl gnupg
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Enable and start Docker
systemctl enable docker
systemctl start docker

# Create airflow directory
mkdir -p /opt/airflow/{dags,logs,plugins,config}
cd /opt/airflow

# Write docker-compose.yaml
cat > docker-compose.yaml <<'EOF'
${docker_compose}
EOF

# Write systemd service file
cat > /etc/systemd/system/airflow.service <<'EOF'
${airflow_service}
EOF

# Write initialization script
cat > init-airflow.sh <<'EOF'
${init_script}
EOF
chmod +x init-airflow.sh

# Run initialization
./init-airflow.sh

# Start services
docker compose up -d

# Enable systemd service for auto-start
systemctl daemon-reload
systemctl enable airflow.service

echo "Airflow installation complete!"
echo "Access at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
echo "Username: admin"
echo "Password: admin"
