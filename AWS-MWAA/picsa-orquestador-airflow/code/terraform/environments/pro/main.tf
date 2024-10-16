################################################################################
###################               Global data              #####################
################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
###################                  IAM                   #####################
################################################################################

module "iam" {
  source = "../../modules/iam"

  name_prefix = "${var.prefix}-${var.env}"
  bucket_arn  = module.s3_mwaa.bucket_arn
  region      = data.aws_region.current.name
  account_id  = data.aws_caller_identity.current.account_id
}

################################################################################
###################                  VPC                   #####################
################################################################################

module "vpc" {
  source = "../../modules/vpc"

  name                  = "${var.prefix}-${var.env}"
  cidr                  = "10.0.0.0/16"
  azs                   = var.azs
  private_subnets       = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets        = ["10.0.101.0/24", "10.0.102.0/24"]
  private_subnets_names = ["${var.prefix}-${var.env}-private-subnet-a", "${var.prefix}-${var.env}-private-subnet-b"]
  public_subnets_names  = ["${var.prefix}-${var.env}-public-subnet-a", "${var.prefix}-${var.env}-public-subnet-b"]
}

################################################################################
###################                   S3                   #####################
################################################################################

module "s3_mwaa" {
  source = "../../modules/s3"

  bucket_name             = "${var.prefix}-${var.env}"
  versioning              = "Enabled"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
###################               S3 objects               #####################
################################################################################

module "example_dags" {
  source = "../../modules/s3_objects"

  for_each     = fileset("../../../dags/", "*.py")
  bucket_id    = module.s3_mwaa.bucket_id
  files_key    = "dags/${each.value}"
  files_source = "../../../dags/${each.value}"
  files_etag   = filemd5("../../../dags/${each.value}")
}

################################################################################
###################                  MWAA                  #####################
################################################################################

module "mwaa" {
  source = "../../modules/mwaa"

  name                  = "${var.prefix}-${var.env}"
  dags_s3_bucket        = module.s3_mwaa.bucket_arn
  dags_s3_path          = "dags/"
  execution_role_arn    = module.iam.role_arn
  environment_class     = "mw1.small"
  mwaa_min_workers      = "2"
  mwaa_max_workers      = "4"
  webserver_access_mode = "PUBLIC_ONLY"

  security_group_ids = [module.vpc.default_security_group_id]
  subnets_ids        = module.vpc.private_subnets

  dag_logs            = true
  dag_log_level       = "INFO"
  scheduler_logs      = true
  scheduler_log_level = "INFO"
  task_logs           = true
  task_log_level      = "INFO"
  webserver_logs      = true
  webserver_log_level = "INFO"
  worker_logs         = true
  worker_log_level    = "INFO"
}
