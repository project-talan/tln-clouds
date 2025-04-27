locals {
  tags = { group = var.group_id, env = var.env_id }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  filter {
    name   = "tag:Name"
    values = [module.shared.vpc_name]
  }
}

data "aws_subnets" "private" {
  tags = merge(module.shared.tags, local.tags, module.shared.private_subnet_tags)
}

data "aws_subnets" "public" {
  tags = merge(module.shared.tags, local.tags, module.shared.public_subnet_tags)
}

data "aws_security_group" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["${var.env_id}-bastion-sg"]
  }

  filter {
    name   = "tag:env"
    values = [var.env_id]
  }

  vpc_id = data.aws_vpc.main.id
}
