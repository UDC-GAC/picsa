################################################################################
###################                Lambda                  #####################
################################################################################

data "archive_file" "lambda_package" {
  type        = "zip"
  source_file = var.source_file
  output_path = var.output_path
}

resource "aws_iam_policy" "lambda_package" {
  name        = var.policy_name
  path        = var.path
  description = var.policy_description

  policy = var.policy_file
}

resource "aws_iam_role" "lambda_package" {
  name                  = var.role_name
  description           = var.role_description
  force_detach_policies = var.force_detach_policies

  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "lambda_glue_role_policy_attachment" {
  role       = aws_iam_role.lambda_package.name
  policy_arn = aws_iam_policy.lambda_package.arn
}

resource "aws_lambda_function" "lambda_package" {
  filename         = data.archive_file.lambda_package.output_path
  function_name    = var.function_name
  role             = aws_iam_role.lambda_package.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  environment {
    variables = var.environment
  }
}
