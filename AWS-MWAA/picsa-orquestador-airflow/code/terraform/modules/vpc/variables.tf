################################################################################
###################                  VPC                   #####################
################################################################################

variable "name" {
  type        = string
  description = "VPC name"
}

variable "cidr" {
  type        = string
  description = "Classless Inter-Domain Routing for your VPC"
}

variable "azs" {
  type        = list(string)
  description = "List of Availability Zones for your VPC"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of IP Ranges for your private subnets"
}

variable "private_subnets_names" {
  type        = list(string)
  description = "List of names for your private subnets"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of IP Ranges for your public subnets"
}

variable "public_subnets_names" {
  type        = list(string)
  description = "List of names for your public subnets"
}
