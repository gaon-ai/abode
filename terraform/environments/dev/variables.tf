variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
  default     = "abode-flinks-dev"
}

variable "vendor_aws_account_id" {
  description = "AWS account ID of the vendor"
  type        = string
}

variable "external_id" {
  description = "External ID for AssumeRole"
  type        = string
  sensitive   = true
}

variable "data_prefix" {
  description = "S3 prefix for production data"
  type        = string
  default     = "login-ids"
}

variable "test_prefix" {
  description = "S3 prefix for test data"
  type        = string
  default     = "test-login-ids"
}

variable "enable_test_prefix" {
  description = "Enable test prefix access for vendor"
  type        = bool
  default     = true
}

variable "role_max_session_duration" {
  description = "Maximum session duration in seconds"
  type        = number
  default     = 3600
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules"
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Days before transitioning to Glacier"
  type        = number
  default     = 90
}

variable "data_retention_days" {
  description = "Days before deletion"
  type        = number
  default     = 365
}

variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "S3 bucket for access logs"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default = {
    Team   = "Data Engineering"
    Vendor = "Flinks"
  }
}
