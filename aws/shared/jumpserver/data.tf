data "aws_region" "current" {
  provider = aws
}
data "aws_vpc" "jumpserver" {
  default = (var.use_default_vpc == true) ? true : false
  id      = var.vpc_id
}

data "aws_security_group" "jumpserver" {
  name   = "default"
  vpc_id = data.aws_vpc.jumpserver.id
}
