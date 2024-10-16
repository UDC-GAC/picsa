################################################################################
###################                  VPC                   #####################
################################################################################

output "name" {
  value = module.vpc.name
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "vpc_arn" {
  value = module.vpc.vpc_arn
}

output "cidr_block" {
  value = module.vpc.vpc_cidr_block
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "default_security_group_id" {
  value = aws_security_group.vpc_self_access.id
}

output "igw_id" {
  value = module.vpc.igw_id
}
