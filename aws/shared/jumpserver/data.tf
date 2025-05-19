data "aws_region" "current" {
  provider = aws
}
data "aws_vpc" "jumpbox" {
  default = (var.use_default_vpc == true) ? true : false
  id      = var.vpc_id
}

data "aws_security_group" "jumpbox" {
  name   = "default"
  vpc_id = data.aws_vpc.jumpbox.id
}
