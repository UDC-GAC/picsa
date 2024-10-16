################################################################################
###################                  IAM                   #####################
################################################################################

variable "name_prefix" {
  type = string
  description = "Prefix to add to all IAM resources name"
}

variable "bucket_arn" {
  type = string
  description = "S3 bucket ARN to upload DAGs scripts"
}

variable "account_id" {
  type = string
  description = "AWS Account id where resources will be deployed"
}

variable "region" {
  type = string
  description = "The deployment region"
}
