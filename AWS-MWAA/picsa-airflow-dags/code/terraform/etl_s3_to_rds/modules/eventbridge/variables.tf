################################################################################
###################              EventBridge               #####################
################################################################################

variable "name" {
  type        = string
  description = "The name of the rule"
}

variable "description" {
  type        = string
  description = "The description of the rule"
}

variable "schedule" {
  type        = string
  description = "The scheduling expression"
}

variable "enabled" {
  type        = bool
  description = "Whether the rule should be enabled"
}

variable "rule" {
  type        = string
  description = "The name of the rule you want to add targets to"
}

variable "lambda_arn" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the target"
}
