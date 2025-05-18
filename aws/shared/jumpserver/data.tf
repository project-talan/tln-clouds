data "aws_vpc" "jumpbox" {
  default = var.vpc_id == null ? true : false
  id      = var.vpc_id
}

data "aws_security_group" "jumpbox" {
  name   = (var.vpc_id == null || var.vpc_id == "") ? "default" : "${var.resources_prefix}-sg"
  vpc_id = data.aws_vpc.jumpbox.id
}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.jumpbox.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["false"]
  }
}

data "aws_subnets" "public" {

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.jumpbox.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

