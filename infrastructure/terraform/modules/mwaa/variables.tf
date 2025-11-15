variable "environment_name" {
  description = "Name of the MWAA environment"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "airflow_version" {
  description = "Airflow version for MWAA"
  type        = string
  default     = "2.8.1"
}

variable "environment_class" {
  description = "Environment class for MWAA (mw1.small, mw1.medium, mw1.large, mw1.xlarge, mw1.2xlarge)"
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
  description = "Webserver access mode (PUBLIC_ONLY or PRIVATE_ONLY)"
  type        = string
  default     = "PUBLIC_ONLY"
}

variable "vpc_id" {
  description = "VPC ID where MWAA will be deployed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for MWAA"
  type        = list(string)
}

variable "dag_s3_path" {
  description = "S3 path for DAGs (relative to bucket root)"
  type        = string
  default     = "dags"
}

variable "requirements_s3_path" {
  description = "S3 path for requirements.txt (relative to bucket root)"
  type        = string
  default     = "requirements.txt"
}

variable "plugins_s3_path" {
  description = "S3 path for plugins.zip (relative to bucket root)"
  type        = string
  default     = "plugins.zip"
}

variable "airflow_configuration_options" {
  description = "Airflow configuration options"
  type        = map(string)
  default     = {}
}

variable "logging_configuration" {
  description = "Logging configuration for MWAA"
  type = object({
    dag_processing_logs = object({
      enabled   = bool
      log_level = string
    })
    scheduler_logs = object({
      enabled   = bool
      log_level = string
    })
    task_logs = object({
      enabled   = bool
      log_level = string
    })
    webserver_logs = object({
      enabled   = bool
      log_level = string
    })
    worker_logs = object({
      enabled   = bool
      log_level = string
    })
  })
  default = {
    dag_processing_logs = {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs = {
      enabled   = true
      log_level = "INFO"
    }
    task_logs = {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs = {
      enabled   = true
      log_level = "INFO"
    }
    worker_logs = {
      enabled   = true
      log_level = "INFO"
    }
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "weekly_maintenance_window_start" {
  description = "Weekly maintenance window start (e.g., MON:03:00)"
  type        = string
  default     = null
}
