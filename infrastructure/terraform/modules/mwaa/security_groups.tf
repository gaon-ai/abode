resource "aws_security_group" "mwaa" {
  name        = "${var.environment_name}-mwaa-sg-${var.environment}"
  description = "Security group for MWAA environment"
  vpc_id      = var.vpc_id

  ingress {
    description = "Allow all traffic from within security group"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment_name}-mwaa-sg-${var.environment}"
      Environment = var.environment
    }
  )
}
