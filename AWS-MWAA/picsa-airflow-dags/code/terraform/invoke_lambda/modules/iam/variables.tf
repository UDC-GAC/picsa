################################################################################
###################                  IAM                   #####################
################################################################################

variable "name_prefix" {
  type        = string
  description = "Prefix to IAM policy resource"
}

variable "lambda_arn" {
  type        = string
  description = "Lambda ARN"
}

variable "airflow_role_name" {
  type        = string
  description = "MWAA role name"
}
