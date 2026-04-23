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

data "aws_security_group" "node" {
  vpc_id = data.aws_vpc.primary.id

  filter {
    name   = "tag:Name"
    values = ["${module.shared.k8s_name}-node"]
  }
}

data "aws_security_group" "bastion" {
  filter {
    name   = "tag:Name"
    values = ["${module.shared.prefix_env}-bastion"]
  }

  vpc_id = data.aws_vpc.primary.id
}


data "aws_eks_cluster" "eks" {
  name = module.shared.k8s_name
}

data "aws_lb" "primary" {
  tags = {
    "elbv2.k8s.aws/cluster" = "${module.shared.k8s_name}",
    "service.k8s.aws/stack" = "nginx-ingress/nginx-ingress-nginx-controller"
  }

  depends_on = [
    helm_release.nginx
  ]  
}

data "aws_ses_domain_identity" "primary" {
  domain = var.domain_name
}

data "aws_region" "current" {
  provider = aws
}

data "aws_iam_openid_connect_provider" "example" {
  url = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "oidc_provider_arn" {
  value = data.aws_iam_openid_connect_provider.example.arn
}
