################################################################################
###################                  MWAA                  #####################
################################################################################

resource "aws_mwaa_environment" "mwaa" {
  name                  = var.name
  source_bucket_arn     = var.dags_s3_bucket
  dag_s3_path           = var.dags_s3_path
  execution_role_arn    = var.execution_role_arn
  environment_class     = var.environment_class
  min_workers           = var.mwaa_min_workers
  max_workers           = var.mwaa_max_workers
  webserver_access_mode = var.webserver_access_mode 

  network_configuration {
    security_group_ids = var.security_group_ids
    subnet_ids         = var.subnets_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = var.dag_logs
      log_level = var.dag_log_level
    }

    scheduler_logs {
      enabled   = var.scheduler_logs
      log_level = var.scheduler_log_level
    }

    task_logs {
      enabled   = var.task_logs
      log_level = var.task_log_level
    }

    webserver_logs {
      enabled   = var.webserver_logs
      log_level = var.webserver_log_level
    }

    worker_logs {
      enabled   = var.worker_logs
      log_level = var.worker_log_level
    }
  }
}
