################################################################################
###################                  RDS                   #####################
################################################################################

output "cluster_arn" {
  value       = module.etl_s3_to_rds.cluster_arn
  description = "Aurora Cluster AWS ARN"
}

output "cluster_id" {
  value       = module.etl_s3_to_rds.cluster_id
  description = "Aurora Cluster AWS ID"
}

output "cluster_endpoint" {
  value       = module.etl_s3_to_rds.cluster_endpoint
  description = "Aurora Cluster writer endpoint"
}

output "cluster_reader_endpoint" {
  value       = module.etl_s3_to_rds.cluster_reader_endpoint
  description = "Aurora Cluster reader endpoint"
}

output "cluster_database_name" {
  value       = module.etl_s3_to_rds.cluster_database_name
  description = "Database name"
}

output "cluster_master_username" {
  value       = module.etl_s3_to_rds.cluster_master_username
  description = "Database root username"
  sensitive   = true
}

output "cluster_master_password" {
  value       = module.etl_s3_to_rds.cluster_master_password
  description = "Database root password"
  sensitive   = true
}

output "cluster_port" {
  value       = module.etl_s3_to_rds.cluster_port
  description = "RDS instance port to connect to the database"
}
