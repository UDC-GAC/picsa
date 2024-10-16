################################################################################
###################               Global data              #####################
################################################################################

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

################################################################################
###################                   S3                   #####################
################################################################################

module "invoke_lambda_bucket" {
  source = "../../modules/s3"

  bucket_name             = "${var.prefix}-${var.env}"
  versioning              = "Enabled"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

################################################################################
###################                  IAM                   #####################
################################################################################

module "invoke_lambda_permissions" {
  source = "../../modules/iam"

  name_prefix       = "${var.prefix}-${var.env}"
  lambda_arn        = module.invoke_lambda.lambda_arn
  airflow_role_name = "${var.airflow_prefix}-pro-airflow-role"
}

################################################################################
###################               S3 objects               #####################
################################################################################

###################             invoke_lambda              #####################

module "invoke_lambda_dag" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "dags/invoke_lambda/invoke_lambda.py"
  files_source = "../../../../dags/invoke_lambda/invoke_lambda.py"
  files_etag   = filemd5("../../../../dags/invoke_lambda/invoke_lambda.py")
}

module "invoke_lambda_requirements" {
  source = "../../modules/s3_objects"

  bucket_id    = "${var.airflow_prefix}-${var.env}"
  files_key    = "requirements/invoke_lambda/requirements.txt"
  files_source = "../../../../dags/invoke_lambda/requirements.txt"
  files_etag   = filemd5("../../../../dags/invoke_lambda/requirements.txt")
}

################################################################################
###################                Lambda                  #####################
################################################################################

module "invoke_lambda" {
  source = "../../modules/lambda"

  source_file = "./lambda_functions/invoke_lambda.py"
  output_path = "./lambda_functions/invoke_lambda.zip"

  policy_name        = "${var.prefix}-${var.env}-invoke-lambda"
  path               = "/"
  policy_description = "Policy for the role of the lambda that stop RDS cluster of ${var.prefix} project on ${var.env} environment"
  policy_file = templatefile("./templates/iam_policies/s3PutObject.tftpl",
    {
      invoke_lambda_bucket_name = module.invoke_lambda_bucket.bucket_arn
    }
  )

  role_name             = "${var.prefix}-${var.env}-invoke-lambda"
  role_description      = "Role of the lambda that access to S3 and upload files"
  force_detach_policies = true
  assume_role_policy    = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

  function_name = "airflowLambdaToS3"
  handler       = "invoke_lambda.lambda_handler"
  runtime       = "python3.9"
  timeout       = 300
  environment = {
    s3_bucket = module.invoke_lambda_bucket.bucket_id
  }
}
