variable "environment_name" {
  description = "Name of the MWAA environment"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where MWAA will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for MWAA"
  type        = list(string)
}

variable "airflow_version" {
  description = "Airflow version for MWAA"
  type        = string
  default     = "2.8.1"
}

variable "environment_class" {
  description = "Environment class for MWAA"
  type        = string
  default     = "mw1.small"
}

variable "max_workers" {
  description = "Maximum number of workers"
  type        = number
  default     = 1
}

variable "min_workers" {
  description = "Minimum number of workers"
  type        = number
  default     = 1
}

variable "schedulers" {
  description = "Number of schedulers"
  type        = number
  default     = 2
}

variable "webserver_access_mode" {
  description = "Webserver access mode"
  type        = string
  default     = "PUBLIC_ONLY"
}

variable "dag_s3_path" {
  description = "S3 path for DAGs"
  type        = string
  default     = "dags"
}
