################################################################################
###################                   S3                   #####################
################################################################################

variable "bucket_name" {
  type = string
  description = "S3 bucket name to store dag scripts"
}

variable "versioning" {
  type = string
  description = "Allows bucket versioning (select Enabled or Disabled)"
}

variable "block_public_acls" {
  type = bool
  description = "Boolean to block public ACLs"
}

variable "block_public_policy" {
  type = bool
  description = "Boolean to block public policies"
}

variable "ignore_public_acls" {
  type = bool
  description = "Boolean to ignore public ACLs"
}

variable "restrict_public_buckets" {
  type = bool
  description = "Boolean to restrict public buckets"
}
