resource "aws_s3_bucket" "mwaa" {
  bucket = "${var.environment_name}-mwaa-${var.environment}"

  tags = merge(
    var.tags,
    {
      Name        = "${var.environment_name}-mwaa-${var.environment}"
      Environment = var.environment
    }
  )
}

resource "aws_s3_bucket_versioning" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "mwaa" {
  bucket = aws_s3_bucket.mwaa.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Create placeholder DAG directory structure
resource "aws_s3_object" "dags_folder" {
  bucket  = aws_s3_bucket.mwaa.id
  key     = "${var.dag_s3_path}/"
  content = ""

  tags = var.tags
}
