################################################################################
###################               Global data              #####################
################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
###################                   S3                   #####################
################################################################################

module "raw_data_bucket" {
  source = "../../modules/s3"

  bucket_name             = "${var.prefix}-${var.env}"
  versioning              = "Enabled"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
###################               S3 objects               #####################
################################################################################

###################             etl_s3_to_rds              #####################

module "s3_to_rds_pandas_dag" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "dags/etl_s3_to_rds_pandas/etl_s3_to_rds_pandas.py"
  files_source = "../../../../dags/etl_s3_to_rds_pandas/etl_s3_to_rds_pandas.py"
  files_etag   = filemd5("../../../../dags/etl_s3_to_rds_pandas/etl_s3_to_rds_pandas.py")
}

module "s3_to_rds_pandas_raw_data_files" {
  source = "../../modules/s3_objects"

  for_each     = fileset("../../../../dags/etl_s3_to_rds_pandas/raw_data", "*.csv")
  bucket_id    = module.raw_data_bucket.bucket_id
  files_key    = "etl_s3_to_rds_pandas/raw_data/${each.value}"
  files_source = "../../../../dags/etl_s3_to_rds_pandas/raw_data/${each.value}"
  files_etag   = filemd5("../../../../dags/etl_s3_to_rds_pandas/raw_data/${each.value}")
}

module "s3_to_rds_pandas_requirements" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "requirements/etl_s3_to_rds_pandas/requirements.txt"
  files_source = "../../../../dags/etl_s3_to_rds_pandas/requirements.txt"
  files_etag   = filemd5("../../../../dags/etl_s3_to_rds_pandas/requirements.txt")
}

###################             etl_rds_to_s3              #####################

module "rds_to_s3_dag" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "dags/etl_rds_to_s3/etl_rds_to_s3.py"
  files_source = "../../../../dags/etl_rds_to_s3/etl_rds_to_s3.py"
  files_etag   = filemd5("../../../../dags/etl_rds_to_s3/etl_rds_to_s3.py")
}

module "rds_to_s3_requirements" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "requirements/etl_rds_to_s3/requirements.txt"
  files_source = "../../../../dags/etl_rds_to_s3/requirements.txt"
  files_etag   = filemd5("../../../../dags/etl_rds_to_s3/requirements.txt")
}

################################################################################
###################                  RDS                   #####################
################################################################################

module "rds" {
  source = "../../modules/rds_aurora"

  name                        = "${var.prefix}-${var.env}"
  engine                      = "aurora-postgresql"
  engine_version              = "14.7"
  database_name               = "airflow"
  master_username             = "root"
  manage_master_user_password = false
  master_password             = "${var.prefix}-${var.env}"
  storage_type                = "aurora-iopt1"

  instances = {
    writer = {
      identifier          = "postgresql-static-writer"
      instance_class      = "db.r5.large"
      publicly_accessible = true
    }
    reader = {
      identifier     = "postgresql-static-reader-1"
      instance_class = "db.r5.large"
    }
  }

  vpc_id                 = "vpc-0642a78247a583d4e"
  create_db_subnet_group = true
  subnets                = ["subnet-0ad217aa87249f108", "subnet-0f1e9aaae48925db2"]
  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  monitoring_interval           = 60
  iam_role_name                 = "${var.prefix}-${var.env}-monitor"
  iam_role_use_name_prefix      = true
  iam_role_description          = "${var.prefix}-${var.env} RDS enhanced monitoring IAM role"
  iam_role_path                 = "/autoscaling/"
  iam_role_max_session_duration = 7200

  performance_insights_enabled          = true
  performance_insights_retention_period = 31

  apply_immediately   = true
  skip_final_snapshot = true

  create_db_cluster_parameter_group      = true
  db_cluster_parameter_group_name        = "${var.prefix}-${var.env}"
  db_cluster_parameter_group_family      = "aurora-postgresql14"
  db_cluster_parameter_group_description = "${var.prefix}-${var.env} example cluster parameter group"
  db_cluster_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 1000
      apply_method = "immediate"
      }, {
      name         = "rds.force_ssl"
      value        = 1
      apply_method = "immediate"
      }, {
      name         = "log_statement"
      value        = "all"
      apply_method = "immediate"
      }, {
      name         = "log_connections"
      value        = true
      apply_method = "immediate"
    }
  ]

  create_db_parameter_group      = true
  db_parameter_group_name        = "${var.prefix}-${var.env}"
  db_parameter_group_family      = "aurora-postgresql14"
  db_parameter_group_description = "${var.prefix}-${var.env} DB parameter group"
  db_parameter_group_parameters = [
    {
      name         = "log_min_duration_statement"
      value        = 1000
      apply_method = "immediate"
      }, {
      name         = "log_statement"
      value        = "all"
      apply_method = "immediate"
      }, {
      name         = "log_connections"
      value        = true
      apply_method = "immediate"
    }
  ]

  create_cloudwatch_log_group     = true
  enabled_cloudwatch_logs_exports = ["postgresql"]
}

################################################################################
###################                Lambda                  #####################
################################################################################

module "stop_rds_cluster_lambda" {
  source = "../../modules/lambda"

  source_file = "./lambda_functions/stop_rds_cluster.py"
  output_path = "./lambda_functions/stop_rds_cluster.zip"

  policy_name        = "${var.prefix}-${var.env}-stop-rds-cluster"
  path               = "/"
  policy_description = "Policy for the role of the lambda that stop RDS cluster of ${var.prefix} project on ${var.env} environment"
  policy_file = templatefile("./templates/iam_policies/changeRDSstatus.tftpl",
    {
      database_cluster_arn = module.rds.cluster_arn
    }
  )

  role_name             = "${var.prefix}-${var.env}-stop-rds-cluster"
  role_description      = "Role of the lambda that stop RDS cluster of ${var.prefix} project on ${var.env} environment"
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  function_name = "${var.prefix}-${var.env}-stop-rds-cluster"
  handler       = "stop_rds_cluster.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  environment = {
    cluster_identifier = module.rds.cluster_id
  }
}

################################################################################
###################              EventBridge               #####################
################################################################################

module "stop_rds_cluster_rule" {
  source = "../../modules/eventbridge"

  name        = "${var.prefix}-${var.env}-stop-rds-cluster"
  description = "Stops ${var.prefix}-${var.env} cluster at 13:00 UTC"
  schedule    = "cron(0 13 * * ? *)"
  enabled     = true

  rule       = module.stop_rds_cluster_rule.rule_name
  lambda_arn = module.stop_rds_cluster_lambda.lambda_arn
}
