output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.airflow.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.airflow.public_ip
}

output "airflow_url" {
  description = "Airflow web UI URL"
  value       = "http://${aws_instance.airflow.public_ip}:8080"
}

output "ssh_command" {
  description = "SSH command to connect to instance"
  value       = "ssh -i ~/.ssh/${var.ssh_key_name}.pem ubuntu@${aws_instance.airflow.public_ip}"
}

output "security_group_id" {
  description = "Security group ID"
  value       = aws_security_group.airflow.id
}
