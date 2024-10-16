################################################################################
###################                  IAM                   #####################
################################################################################

resource "aws_iam_role" "airflow" {
  name = "${var.name_prefix}-airflow-role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = "mwaa"
        Principal = {
          Service = [
            "airflow-env.amazonaws.com",
            "airflow.amazonaws.com"
          ]
        }
      },
    ]
  })
}

resource "aws_iam_policy" "airflow" {
  name   = "${var.name_prefix}-airflow-policy"
  path   = "/"
  description = "IAM policy to allow airflow to operate in AWS"

  policy = templatefile("../../modules/iam/policy_templates/airflow.tmpl",
    {
      s3_bucket_arn = format("%s", var.bucket_arn),
      region = format("%s", var.region),
      account_id = format("%s", var.account_id),
      name_prefix = format("%s", var.name_prefix)
    }
  )
}

resource "aws_iam_role_policy_attachment" "iam_role_policy_attachment" {
  role       = aws_iam_role.airflow.name
  policy_arn = aws_iam_policy.airflow.arn
}

resource "aws_iam_user" "dags" {
  name = "${var.name_prefix}-dags"
}

resource "aws_iam_access_key" "dags" {
  user = aws_iam_user.dags.name
}

resource "aws_iam_policy" "dags" {
  name   = "${var.name_prefix}-dags-policy"
  path   = "/"
  description = "IAM policy to allow upload and delete dags scripts on S3"

  policy = templatefile("../../modules/iam/policy_templates/dags.tmpl",
    {
      s3_bucket_arn = format("%s", var.bucket_arn)
    }
  )

}

resource "aws_iam_policy_attachment" "dags" {
  name       = "${var.name_prefix}-dags-policy-attachment"
  users      = [aws_iam_user.dags.name]
  policy_arn = aws_iam_policy.dags.arn
}
