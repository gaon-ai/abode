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
  default     = "prod"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24", "10.1.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.1.101.0/24", "10.1.102.0/24", "10.1.103.0/24"]
}

variable "airflow_version" {
  description = "Airflow version"
  type        = string
  default     = "2.8.1"
}

variable "environment_class" {
  description = "MWAA environment class"
  type        = string
  default     = "mw1.medium"
}

variable "max_workers" {
  description = "Maximum number of workers"
  type        = number
  default     = 25
}

variable "min_workers" {
  description = "Minimum number of workers"
  type        = number
  default     = 2
}

variable "schedulers" {
  description = "Number of schedulers"
  type        = number
  default     = 2
}

variable "webserver_access_mode" {
  description = "Webserver access mode"
  type        = string
  default     = "PRIVATE_ONLY"
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
    "webserver.expose_config"                     = "False"
    "webserver.hide_paused_dags_by_default"       = "True"
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
      enabled   = true
      log_level = "WARNING"
    }
    worker_logs = {
      enabled   = true
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
