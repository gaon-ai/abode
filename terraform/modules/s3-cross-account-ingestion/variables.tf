# Required variables

variable "environment" {
  description = "Environment name (dev, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "Environment must be either 'dev' or 'prod'."
  }
}

variable "bucket_name" {
  description = "Name of the S3 bucket for data ingestion"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be lowercase alphanumeric with hyphens."
  }
}

variable "vendor_aws_account_id" {
  description = "AWS account ID of the vendor that will upload data"
  type        = string

  validation {
    condition     = can(regex("^[0-9]{12}$", var.vendor_aws_account_id))
    error_message = "Vendor AWS account ID must be a 12-digit number."
  }
}

variable "external_id" {
  description = "External ID for AssumeRole security (should be a secret shared with vendor)"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.external_id) >= 8
    error_message = "External ID must be at least 8 characters long."
  }
}

# Optional variables with defaults

variable "data_prefix" {
  description = "S3 prefix where vendor will upload data files"
  type        = string
  default     = "login-ids"
}

variable "test_prefix" {
  description = "S3 prefix for vendor testing (optional)"
  type        = string
  default     = "test-login-ids"
}

variable "enable_test_prefix" {
  description = "Whether to grant vendor access to test prefix"
  type        = bool
  default     = false
}

variable "role_max_session_duration" {
  description = "Maximum session duration for the IAM role in seconds (1 hour to 12 hours)"
  type        = number
  default     = 3600

  validation {
    condition     = var.role_max_session_duration >= 3600 && var.role_max_session_duration <= 43200
    error_message = "Session duration must be between 3600 (1 hour) and 43200 (12 hours) seconds."
  }
}

variable "enable_lifecycle_rules" {
  description = "Enable lifecycle rules for cost optimization"
  type        = bool
  default     = true
}

variable "glacier_transition_days" {
  description = "Number of days before transitioning objects to Glacier"
  type        = number
  default     = 90
}

variable "data_retention_days" {
  description = "Number of days to retain data before deletion (7 years = 2555 days)"
  type        = number
  default     = 2555
}

variable "enable_access_logging" {
  description = "Enable S3 access logging"
  type        = bool
  default     = false
}

variable "access_log_bucket" {
  description = "S3 bucket for access logs (required if enable_access_logging is true)"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}
