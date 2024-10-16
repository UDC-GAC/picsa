################################################################################
###################            Global variables            #####################
################################################################################

variable "prefix" {
  type        = string
  description = "Prefix used for name all AWS resources (project name)"
  default     = "etl-s3-to-rds"
}

variable "env" {
  type        = string
  description = "Name of the environment"
  default     = "dev"
}

variable "tags" {
  type        = map(any)
  description = "Default assigned tags to the resources deployed with this Terraform"
  default = {
    "project"        = "PID-21014-PICSA"
    "project_number" = "3261"
    "provider"       = "terraform"
  }
}

variable "region" {
  type        = string
  description = "AWS Region where Terraform will be deployed"
  default     = "ap-southeast-1"
}

variable "azs" {
  type        = list(string)
  description = "Avaliability zones list"
  default     = ["ap-southeast-1a", "ap-southeast-1b"]
}

variable "profile" {
  type        = string
  description = "AWS Profile with permissions to deploy this Terraform"
  default     = "torusware"
}
