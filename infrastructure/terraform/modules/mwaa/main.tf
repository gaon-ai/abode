resource "aws_mwaa_environment" "this" {
  name = var.environment_name

  airflow_version       = var.airflow_version
  environment_class     = var.environment_class
  execution_role_arn    = aws_iam_role.mwaa.arn
  webserver_access_mode = var.webserver_access_mode

  source_bucket_arn = aws_s3_bucket.mwaa.arn
  dag_s3_path       = var.dag_s3_path

  max_workers = var.max_workers
  min_workers = var.min_workers
  schedulers  = var.schedulers

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.private_subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "WARNING"
    }

    scheduler_logs {
      enabled   = true
      log_level = "WARNING"
    }

    task_logs {
      enabled   = true
      log_level = "INFO"
    }

    webserver_logs {
      enabled   = false
      log_level = "WARNING"
    }

    worker_logs {
      enabled   = false
      log_level = "WARNING"
    }
  }

  depends_on = [
    aws_iam_role_policy.mwaa
  ]
}
