resource "aws_vpc_security_group_ingress_rule" "allow_bastion_main" {
  security_group_id            = var.rds_security_group_id_main
  referenced_security_group_id = var.bastion_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow Postgresql traffic from bastion"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion_emteko" {
  security_group_id            = var.rds_security_group_id_emteko
  referenced_security_group_id = var.bastion_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow Postgresql traffic from bastion"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}