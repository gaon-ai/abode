# Get latest Ubuntu 22.04 ARM64 AMI
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Security Group
resource "aws_security_group" "airflow" {
  name        = "${var.project_name}-airflow-${var.environment}"
  description = "Security group for Airflow EC2"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr
  }

  ingress {
    description = "Airflow Web UI"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = var.allowed_web_cidr
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-airflow-${var.environment}"
    Environment = var.environment
  }
}

# EC2 Instance
resource "aws_instance" "airflow" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = var.instance_type
  key_name      = var.ssh_key_name

  vpc_security_group_ids = [aws_security_group.airflow.id]

  root_block_device {
    volume_type = "gp3"
    volume_size = var.volume_size
    encrypted   = true
  }

  user_data = templatefile("${path.module}/user-data.sh", {
    docker_compose = file("${path.module}/files/docker-compose.yaml")
    init_script = file("${path.module}/files/init-airflow.sh")
  })

  tags = {
    Name        = "${var.project_name}-airflow-${var.environment}"
    Environment = var.environment
  }
}
