################################################################################
###################                  VPC                   #####################
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name = var.name
  cidr = var.cidr

  azs             = var.azs
  private_subnets = var.private_subnets
  public_subnets  = var.public_subnets

  private_subnet_names = var.private_subnets_names
  public_subnet_names  = var.public_subnets_names

  enable_nat_gateway = true
  single_nat_gateway = false
  reuse_nat_ips = true
  external_nat_ip_ids = "${aws_eip.nat.*.id}"
}

resource "aws_security_group" "vpc_self_access" {
  name        = "allow_self_trafic"
  description = "Allow self traffic"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = module.vpc.vpc_id
}

resource "aws_eip" "nat" {
  count = length(var.private_subnets)

  domain = "vpc"
}
