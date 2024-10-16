# invoke_lambda providers

terraform {
  required_version = "= 1.2.8"
  backend "s3" {}
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region  = var.region
  profile = var.profile
  default_tags {
    tags = merge(var.tags, { "env" = terraform.workspace })
  }
}
