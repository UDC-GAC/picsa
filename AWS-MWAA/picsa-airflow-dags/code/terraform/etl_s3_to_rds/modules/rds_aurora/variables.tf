################################################################################
###################                  RDS                   #####################
################################################################################

variable "name" {
  type        = string
  description = "Name used across resources created"
}

variable "engine" {
  type        = string
  description = "The name of the database engine to be used for this DB cluster"
}

variable "engine_version" {
  type        = string
  description = "The database engine version"
}

variable "database_name" {
  type        = string
  description = "Name for an automatically created database on cluster creation"
}

variable "master_username" {
  type        = string
  description = "Username for the master DB user"
}

variable "master_password" {
  type        = string
  description = "Password for the master DB user"
}

variable "manage_master_user_password" {
  type        = bool
  description = "Set to true to allow RDS to manage the master user password in Secrets Manager. Cannot be set if `master_password` is provided"
}

variable "storage_type" {
  type        = string
  description = "Specifies the storage type to be associated with the DB cluster"
}

variable "instances" {
  type        = map(map(any))
  description = "Map of cluster instances and any specific/overriding attributes to be created"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC where to create security group"
}

variable "subnets" {
  type        = list(string)
  description = "List of subnet IDs used by database subnet group created"
}

variable "create_db_subnet_group" {
  type        = bool
  description = "Determines whether to create the database subnet group or use existing"
}

variable "security_group_rules" {
  type        = any
  description = "Map of security group rules to add to the cluster security group created"
}

variable "monitoring_interval" {
  type        = number
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for instances."
}

variable "iam_role_name" {
  type        = string
  description = " Friendly name of the monitoring role"
}

variable "iam_role_use_name_prefix" {
  type        = bool
  description = "Determines whether to use iam_role_name as is or create a unique name beginning with the iam_role_name as the prefix"
}

variable "iam_role_description" {
  type        = string
  description = "Description of the monitoring role"
}

variable "iam_role_path" {
  type        = string
  description = "Path for the monitoring role "
}

variable "iam_role_max_session_duration" {
  type        = number
  description = "Maximum session duration (in seconds) that you want to set for the monitoring role"
}

variable "performance_insights_enabled" {
  type        = bool
  description = "Specifies whether Performance Insights is enabled or not"
}

variable "performance_insights_retention_period" {
  type        = number
  description = "Amount of time in days to retain Performance Insights data"
}

variable "apply_immediately" {
  type        = bool
  description = "Specifies whether any cluster modifications are applied immediately, or during the next maintenance window"
}

variable "skip_final_snapshot" {
  type        = bool
  description = "Determines whether a final snapshot is created before the cluster is deleted. If true is specified, no snapshot is created"
}

variable "create_db_cluster_parameter_group" {
  type        = bool
  description = "Determines whether a cluster parameter should be created or use existing"
}

variable "db_cluster_parameter_group_name" {
  type        = string
  description = "The name of the DB cluster parameter group"
}

variable "db_cluster_parameter_group_family" {
  type        = string
  description = "The family of the DB cluster parameter group"
}

variable "db_cluster_parameter_group_description" {
  type        = string
  description = "The description of the DB cluster parameter group."
}

variable "db_cluster_parameter_group_parameters" {
  type        = list(map(any))
  description = "A list of DB cluster parameters to apply. Note that parameters may differ from a family to an other"
}

variable "create_db_parameter_group" {
  type        = bool
  description = "Determines whether a DB parameter should be created or use existing"
}

variable "db_parameter_group_name" {
  type        = string
  description = "The name of the DB parameter group"
}

variable "db_parameter_group_family" {
  type        = string
  description = "The family of the DB parameter group"
}

variable "db_parameter_group_description" {
  type        = string
  description = "The description of the DB parameter group."
}

variable "db_parameter_group_parameters" {
  type        = list(map(any))
  description = "A list of DB parameters to apply. Note that parameters may differ from a family to an other"
}

variable "create_cloudwatch_log_group" {
  type        = bool
  description = "Determines whether a CloudWatch log group is created for each enabled_cloudwatch_logs_exports"
}

variable "enabled_cloudwatch_logs_exports" {
  type        = list(string)
  description = "Set of log types to export to cloudwatch. If omitted, no logs will be exported."
}
