################################################################################
###################               S3 objects               #####################
################################################################################

output "file_etag" {
  value       = aws_s3_object.dag_script.etag
  description = "S3 upload file ID"
}
