################################################################################
###################                   S3                   #####################
################################################################################

resource "aws_s3_bucket" "s3_bucket_mwaa" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_versioning" "s3_bucket_mwaa" {
  bucket = aws_s3_bucket.s3_bucket_mwaa.id
  versioning_configuration {
    status = var.versioning
  }
}

resource "aws_s3_bucket_public_access_block" "s3_bucket_mwaa_block_public_access" {
  bucket                  = aws_s3_bucket.s3_bucket_mwaa.id
  block_public_acls       = var.block_public_acls
  block_public_policy     = var.block_public_policy
  ignore_public_acls      = var.ignore_public_acls
  restrict_public_buckets = var.restrict_public_buckets
}
