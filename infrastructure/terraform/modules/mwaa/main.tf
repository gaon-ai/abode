resource "aws_mwaa_environment" "this" {
  name = var.environment_name

  airflow_version       = var.airflow_version
  environment_class     = var.environment_class
  execution_role_arn    = aws_iam_role.mwaa.arn
  webserver_access_mode = var.webserver_access_mode
  kms_key               = var.kms_key_arn

  source_bucket_arn = aws_s3_bucket.mwaa.arn
  dag_s3_path       = var.dag_s3_path

  airflow_configuration_options = var.airflow_configuration_options

  max_workers = var.max_workers
  min_workers = var.min_workers
  schedulers  = var.schedulers

  network_configuration {
    security_group_ids = [aws_security_group.mwaa.id]
    subnet_ids         = var.private_subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = var.logging_configuration.dag_processing_logs.enabled
      log_level = var.logging_configuration.dag_processing_logs.log_level
    }

    scheduler_logs {
      enabled   = var.logging_configuration.scheduler_logs.enabled
      log_level = var.logging_configuration.scheduler_logs.log_level
    }

    task_logs {
      enabled   = var.logging_configuration.task_logs.enabled
      log_level = var.logging_configuration.task_logs.log_level
    }

    webserver_logs {
      enabled   = var.logging_configuration.webserver_logs.enabled
      log_level = var.logging_configuration.webserver_logs.log_level
    }

    worker_logs {
      enabled   = var.logging_configuration.worker_logs.enabled
      log_level = var.logging_configuration.worker_logs.log_level
    }
  }

  weekly_maintenance_window_start = var.weekly_maintenance_window_start

  tags = merge(
    var.tags,
    {
      Name        = var.environment_name
      Environment = var.environment
    }
  )

  depends_on = [
    aws_iam_role_policy.mwaa
  ]
}
