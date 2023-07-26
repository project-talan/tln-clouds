data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "main" {
  tags = module.shared.tags
}

data "aws_subnets" "private" {
  tags = merge(module.shared.tags, module.shared.private_subnet_tags)
}

data "aws_subnets" "public" {
  tags = merge(module.shared.tags, module.shared.public_subnet_tags)
}
