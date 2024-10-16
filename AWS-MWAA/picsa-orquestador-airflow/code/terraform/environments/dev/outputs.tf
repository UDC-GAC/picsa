# MWAA output variables

output "mwaa_arn" {
  value       = module.mwaa.mwaa_arn
  description = "ARN of MWAA environment"
}

output "url" {
  value       = module.mwaa.mwwa_url
  description = "Webserver URL of MWAA environment"
}

output "status" {
  value       = module.mwaa.mwaa_status
  description = "MWAA environment webserver status"
}

output "region" {
  value       = data.aws_region.current.name
  description = "The deployment region"
}

output "caller_user" {
  value       = data.aws_caller_identity.current.user_id
  description = "Unique identifier of the calling entity"
  sensitive   = true
}

output "access_key" {
  value       = module.iam.access_key
  description = "Access Key ID to push data to the dags bucket"
  sensitive   = true
}

output "secret_access_key" {
  value       = module.iam.secret_access_key
  description = "Secret Access Key to push data to the dags bucket"
  sensitive   = true
}
