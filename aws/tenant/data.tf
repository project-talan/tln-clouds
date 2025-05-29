data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  subdomain_name = "${var.env_id}.${var.domain_name}"
}

data "aws_vpc" "primary" {
  filter {
    name   = "tag:Name"
    values = [module.shared.vpc_name]
  }
}

data "aws_route53_zone" "primary" {
  name = var.domain_name
}

data "aws_route53_zone" "secondary" {
  name = local.subdomain_name
}

data "aws_acm_certificate" "primary" {
  domain   = var.domain_name
  statuses = ["ISSUED"]
}

data "aws_eks_cluster" "eks" {
  name = module.shared.k8s_name
}

data "aws_lb" "primary" {
  tags = {
    "kubernetes.io/cluster/${module.shared.k8s_name}" = "owned",
    "kubernetes.io/service-name" = "nginx-ingress/nginx-ingress-nginx-controller"
  }
}

data "aws_cognito_user_pool" "primary" {
  user_pool_id = var.user_pool_id
}

data "aws_db_instance" "this" {
  db_instance_identifier = var.db_instance_identifier
}

data "aws_secretsmanager_secret" "rds_pg" {
  arn = data.aws_db_instance.this.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_pg" {
  secret_id = data.aws_secretsmanager_secret.rds_pg.id
}

