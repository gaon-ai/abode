output "instance_id" {
  description = "EC2 instance ID"
  value       = module.airflow.instance_id
}

output "instance_public_ip" {
  description = "Public IP address"
  value       = module.airflow.instance_public_ip
}

output "airflow_url" {
  description = "Airflow web UI URL"
  value       = module.airflow.airflow_url
}

output "ssh_command" {
  description = "SSH command"
  value       = module.airflow.ssh_command
}

output "default_credentials" {
  description = "Default Airflow credentials"
  value = {
    username = "admin"
    password = "admin"
  }
  sensitive = false
}
