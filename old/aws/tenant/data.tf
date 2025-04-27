data "aws_availability_zones" "available" {
  state = "available"
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