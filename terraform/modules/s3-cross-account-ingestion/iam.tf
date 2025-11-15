# IAM role for vendor to assume and upload files to S3
resource "aws_iam_role" "vendor_upload" {
  name        = "${var.bucket_name}-vendor-upload${var.environment != "prod" ? "-${var.environment}" : ""}"
  description = "Cross-account role for vendor to upload data to ${var.bucket_name}"

  max_session_duration = var.role_max_session_duration

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.vendor_aws_account_id}:root"
        }
        Action = "sts:AssumeRole"
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  tags = merge(
    var.tags,
    {
      Name        = "${var.bucket_name}-vendor-upload"
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "Vendor cross-account upload"
    }
  )
}

# IAM policy for least-privilege S3 access
resource "aws_iam_role_policy" "vendor_upload" {
  name = "s3-upload-policy"
  role = aws_iam_role.vendor_upload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucketWithPrefix"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.ingestion.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.data_prefix}/*",
              "${var.data_prefix}"
            ]
          }
        }
      },
      {
        Sid    = "PutObjectsInPrefix"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:AbortMultipartUpload"
        ]
        Resource = "${aws_s3_bucket.ingestion.arn}/${var.data_prefix}/*"
      }
    ]
  })
}

# Optional: Additional policy for test prefix (if enabled)
resource "aws_iam_role_policy" "vendor_upload_test" {
  count = var.enable_test_prefix ? 1 : 0
  name  = "s3-upload-test-policy"
  role  = aws_iam_role.vendor_upload.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ListBucketTestPrefix"
        Effect = "Allow"
        Action = [
          "s3:ListBucket"
        ]
        Resource = aws_s3_bucket.ingestion.arn
        Condition = {
          StringLike = {
            "s3:prefix" = [
              "${var.test_prefix}/*",
              "${var.test_prefix}"
            ]
          }
        }
      },
      {
        Sid    = "PutObjectsInTestPrefix"
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:PutObjectAcl",
          "s3:PutObjectTagging",
          "s3:AbortMultipartUpload",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.ingestion.arn}/${var.test_prefix}/*"
      }
    ]
  })
}
