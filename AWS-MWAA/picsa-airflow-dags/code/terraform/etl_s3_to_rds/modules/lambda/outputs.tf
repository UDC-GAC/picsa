################################################################################
###################                Lambda                  #####################
################################################################################

output "lambda_arn" {
  value       = aws_lambda_function.lambda_package.arn
  description = "Amazon Resource Name (ARN) identifying your Lambda Function"
}

output "iam_role_arn" {
  value       = aws_iam_role.lambda_package.arn
  description = "Amazon Resource Name (ARN) specifying the role"
}
