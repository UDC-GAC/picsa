################################################################################
###################                  IAM                   #####################
################################################################################

output "role_arn" {
  description = "ARN of created IAM role"
  value       = aws_iam_role.airflow.arn
}

output "user_arn" {
  description = "ARN of created IAM user"
  value       = aws_iam_user.dags.arn
}

output "access_key" {
  value       = aws_iam_access_key.dags.id
  description = "Access Key ID to push data to the dags bucket"
  sensitive   = true
}

output "secret_access_key" {
  value       = aws_iam_access_key.dags.secret
  description = "Secret Access Key to push data to the dags bucket"
  sensitive   = true
}
