################################################################################
###################                   S3                   #####################
################################################################################

output "bucket_id" {
  value       = aws_s3_bucket.s3_bucket.id
  description = "S3 bucket ID"
}

output "bucket_arn" {
  value       = aws_s3_bucket.s3_bucket.arn
  description = "S3 bucket ARN"
}
