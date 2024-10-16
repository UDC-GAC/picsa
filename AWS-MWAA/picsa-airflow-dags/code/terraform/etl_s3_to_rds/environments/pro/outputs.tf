# Outputs for picsa-airflow-dags project

output "caller_user" {
  value       = data.aws_caller_identity.current.user_id
  description = "Unique identifier of the calling entity"
  sensitive   = true
}

output "cluster_endpoint" {
  value       = module.rds.cluster_endpoint
  description = "Aurora Cluster writer endpoint"
}

output "cluster_reader_endpoint" {
  value       = module.rds.cluster_reader_endpoint
  description = "Aurora Cluster reader endpoint"
}

output "cluster_database_name" {
  value       = module.rds.cluster_database_name
  description = "Database name"
}

output "cluster_master_username" {
  value       = module.rds.cluster_master_username
  description = "Database root username"
  sensitive   = true
}

output "cluster_master_password" {
  value       = module.rds.cluster_master_password
  description = "Database root password"
  sensitive   = true
}

output "bucket_id" {
  value       = module.raw_data_bucket.bucket_id
  description = "S3 bucket ID"
}
