################################################################################
###################                  IAM                   #####################
################################################################################

resource "aws_iam_policy" "invoke_lambda" {
  name        = "${var.name_prefix}-policy"
  path        = "/"
  description = "IAM permissions to invoke Lambdas"

  policy = templatefile("../../modules/iam/policy_templates/invoke_lambda.tftpl",
    {
      lambda_arn = format("%s", var.lambda_arn),
    }
  )
}

resource "aws_iam_role_policy_attachment" "invoke_lambda" {
  role       = var.airflow_role_name
  policy_arn = aws_iam_policy.invoke_lambda.arn
}
