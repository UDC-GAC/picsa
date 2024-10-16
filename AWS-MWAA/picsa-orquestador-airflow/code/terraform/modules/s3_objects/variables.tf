################################################################################
###################               S3 objects               #####################
################################################################################

variable "bucket_id" {
  type = string
  description = "S3 bucket ID to upload files"
}

variable "files_key" {
  type = string
  description = "Key for each file"
}

variable "files_source" {
  type = string
  description = "Source of each file"
}

variable "files_etag" {
  type = string
  description = "S3 upload file ID"
}
