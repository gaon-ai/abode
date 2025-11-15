#!/bin/bash

# AWS Credentials Setup Script for Terraform

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"
ENV_EXAMPLE="${SCRIPT_DIR}/.env.example"

echo "================================================"
echo "AWS Credentials Setup for Terraform"
echo "================================================"
echo ""

# Check if .env already exists
if [ -f "$ENV_FILE" ]; then
    echo "⚠️  .env file already exists at: $ENV_FILE"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Aborting. Existing .env file preserved."
        exit 0
    fi
fi

# Copy from example
if [ -f "$ENV_EXAMPLE" ]; then
    cp "$ENV_EXAMPLE" "$ENV_FILE"
    echo "✓ Created .env file from .env.example"
else
    # Create from scratch if example doesn't exist
    cat > "$ENV_FILE" << 'EOF'
# AWS Credentials for Terraform
export AWS_ACCESS_KEY_ID="your-access-key-id"
export AWS_SECRET_ACCESS_KEY="your-secret-access-key"
export AWS_DEFAULT_REGION="us-east-1"
EOF
    echo "✓ Created new .env file"
fi

echo ""
echo "================================================"
echo "IMPORTANT: Edit the .env file with your AWS credentials"
echo "================================================"
echo ""
echo "File location: $ENV_FILE"
echo ""
echo "You can edit it with:"
echo "  vim $ENV_FILE"
echo "  or"
echo "  code $ENV_FILE"
echo ""
echo "After editing, load the credentials with:"
echo "  source $ENV_FILE"
echo ""
echo "Then run terraform commands:"
echo "  cd environments/dev"
echo "  terraform init"
echo "  terraform plan"
echo ""
echo "⚠️  SECURITY NOTE:"
echo "   - The .env file is in .gitignore and will NOT be committed"
echo "   - NEVER share your AWS credentials in chat or email"
echo "   - NEVER commit credentials to git"
echo ""
