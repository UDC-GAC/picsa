################################################################################
###################                  RDS                   #####################
################################################################################

module "etl_s3_to_rds" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "8.3.1"

  name                        = var.name
  engine                      = var.engine
  engine_version              = var.engine_version
  database_name               = var.database_name
  master_username             = var.master_username
  manage_master_user_password = var.manage_master_user_password
  master_password             = var.master_password
  storage_type                = var.storage_type

  instances = var.instances

  vpc_id                 = var.vpc_id
  create_db_subnet_group = var.create_db_subnet_group
  subnets                = var.subnets
  security_group_rules   = var.security_group_rules

  monitoring_interval           = var.monitoring_interval
  iam_role_name                 = var.iam_role_name
  iam_role_use_name_prefix      = var.iam_role_use_name_prefix
  iam_role_description          = var.iam_role_description
  iam_role_path                 = var.iam_role_path
  iam_role_max_session_duration = var.iam_role_max_session_duration

  performance_insights_enabled          = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_retention_period

  apply_immediately   = var.apply_immediately
  skip_final_snapshot = var.skip_final_snapshot

  create_db_cluster_parameter_group      = var.create_db_cluster_parameter_group
  db_cluster_parameter_group_name        = var.db_cluster_parameter_group_name
  db_cluster_parameter_group_family      = var.db_cluster_parameter_group_family
  db_cluster_parameter_group_description = var.db_cluster_parameter_group_description
  db_cluster_parameter_group_parameters  = var.db_cluster_parameter_group_parameters

  create_db_parameter_group      = var.create_db_parameter_group
  db_parameter_group_name        = var.db_parameter_group_name
  db_parameter_group_family      = var.db_parameter_group_family
  db_parameter_group_description = var.db_parameter_group_description
  db_parameter_group_parameters  = var.db_parameter_group_parameters

  create_cloudwatch_log_group     = var.create_cloudwatch_log_group
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
}
