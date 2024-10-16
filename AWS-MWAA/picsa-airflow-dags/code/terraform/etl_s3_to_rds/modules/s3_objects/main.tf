################################################################################
###################               S3 objects               #####################
################################################################################

resource "aws_s3_object" "dag_script" {
  bucket = var.bucket_id
  key    = var.files_key
  source = var.files_source
  etag   = var.files_etag
}
