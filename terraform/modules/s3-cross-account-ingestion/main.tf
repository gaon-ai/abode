# S3 Bucket for cross-account vendor data ingestion
resource "aws_s3_bucket" "ingestion" {
  bucket = var.bucket_name

  tags = merge(
    var.tags,
    {
      Name        = var.bucket_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Vendor data ingestion"
    }
  )
}

# Enable versioning for data protection
resource "aws_s3_bucket_versioning" "ingestion" {
  bucket = aws_s3_bucket.ingestion.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "ingestion" {
  bucket = aws_s3_bucket.ingestion.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket ownership controls - ensure bucket owner owns all objects
resource "aws_s3_bucket_ownership_controls" "ingestion" {
  bucket = aws_s3_bucket.ingestion.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Server-side encryption with S3-managed keys (SSE-S3)
resource "aws_s3_bucket_server_side_encryption_configuration" "ingestion" {
  bucket = aws_s3_bucket.ingestion.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# Lifecycle rules for cost optimization
resource "aws_s3_bucket_lifecycle_configuration" "ingestion" {
  count  = var.enable_lifecycle_rules ? 1 : 0
  bucket = aws_s3_bucket.ingestion.id

  rule {
    id     = "transition-to-glacier"
    status = var.enable_lifecycle_rules ? "Enabled" : "Disabled"

    filter {
      prefix = "${var.data_prefix}/"
    }

    transition {
      days          = var.glacier_transition_days
      storage_class = "GLACIER"
    }

    expiration {
      days = var.data_retention_days
    }
  }

  rule {
    id     = "abort-incomplete-multipart-uploads"
    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}

# Optional: Server access logging
resource "aws_s3_bucket_logging" "ingestion" {
  count  = var.enable_access_logging ? 1 : 0
  bucket = aws_s3_bucket.ingestion.id

  target_bucket = var.access_log_bucket
  target_prefix = "${var.bucket_name}/"
}
