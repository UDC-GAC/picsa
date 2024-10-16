################################################################################
###################                Lambda                  #####################
################################################################################

variable "source_file" {
  type        = string
  description = "Package this file into the archive"
}

variable "output_path" {
  type        = string
  description = "The output of the archive file"
}

variable "policy_name" {
  type        = string
  description = "The name of the policy"
}

variable "path" {
  type        = string
  description = "Path in which to create the policy"
}

variable "policy_description" {
  type        = string
  description = "Description of the IAM policy"
}

variable "policy_file" {
  type        = string
  description = "The policy document"
}

variable "role_name" {
  type        = string
  description = "Friendly IAM role name to match"
}

variable "role_description" {
  type        = string
  description = " Description for the role"
}

variable "force_detach_policies" {
  type        = bool
  description = "Whether to force detaching any policies the role has before destroying it"
}

variable "assume_role_policy" {
  type        = string
  description = "Policy document associated with the role"
}

variable "function_name" {
  type        = string
  description = "Unique name for your Lambda Function"
}

variable "handler" {
  type        = string
  description = "Function entrypoint in your code"
}

variable "runtime" {
  type        = string
  description = " Identifier of the function's runtime"
}

variable "timeout" {
  type        = number
  description = "Amount of time your Lambda Function has to run in seconds"
}

variable "environment" {
  type        = map(any)
  description = "Map of environment variables that are accessible from the function code during execution"
}
