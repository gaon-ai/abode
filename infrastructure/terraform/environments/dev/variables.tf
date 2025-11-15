variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "abode"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "airflow_version" {
  description = "Airflow version"
  type        = string
  default     = "2.8.1"
}

variable "environment_class" {
  description = "MWAA environment class"
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

variable "requirements_s3_path" {
  description = "S3 path for requirements.txt"
  type        = string
  default     = "requirements.txt"
}

variable "airflow_configuration_options" {
  description = "Airflow configuration options"
  type        = map(string)
  default = {
    "core.default_timezone"                       = "utc"
    "core.load_examples"                          = "False"
    "webserver.expose_config"                     = "True"
    "webserver.hide_paused_dags_by_default"       = "False"
  }
}

variable "logging_configuration" {
  description = "Logging configuration"
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
      log_level = "WARNING"
    }
    scheduler_logs = {
      enabled   = true
      log_level = "WARNING"
    }
    task_logs = {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs = {
      enabled   = false
      log_level = "WARNING"
    }
    worker_logs = {
      enabled   = false
      log_level = "WARNING"
    }
  }
}

variable "weekly_maintenance_window_start" {
  description = "Weekly maintenance window start"
  type        = string
  default     = "SUN:03:00"
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}
