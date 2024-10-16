################################################################################
###################              EventBridge               #####################
################################################################################

resource "aws_cloudwatch_event_rule" "rule" {
  name                = var.name
  description         = var.description
  schedule_expression = var.schedule
  is_enabled          = var.enabled
}

resource "aws_cloudwatch_event_target" "target" {
  rule = var.rule
  arn  = var.lambda_arn
}
