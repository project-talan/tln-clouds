# 1. IAM role only (required for access permissions)
module "lb_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.39"

  role_name                              = "${module.shared.k8s_name}-aws-load-balancer-controller"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = data.aws_iam_openid_connect_provider.example.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

# 2. Direct Helm release (without unnecessary ingresses and certificates)
resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  # Equvalent to 'helm upgrade --install'
  upgrade_install = true

  version    = "1.7.2"

  set = [ {
    name  = "clusterName"
    value = "${module.shared.k8s_name}"
  },
    {
    name  = "serviceAccount.create"
    value = "true"
  },
    {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  },
    {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.lb_controller_irsa_role.iam_role_arn
  },
    {
    name  = "vpcId"
    value = data.aws_vpc.main.id
  },
{
    name  = "region"
    value = data.aws_region.current.id # change to you region
  }
        ]
}

#module "aws_eks_lb" {
#  source  = "c0x12c/helm-aws-lb-controller/aws"
#  version = "1.2.1"
#
#  cluster_name        = module.eks.cluster_name
#  namespace           = "kube-system"
#  oidc_provider       = {
#    arn = module.eks.oidc_provider_arn
#    url = module.eks.oidc_provider
#  }
#  certificate_arn     = [aws_acm_certificate.cert.arn] //module.third_certificate.acm_certificate_arn //this certifiate is required for webhook
#  private_subnet      = data.aws_subnets.private.ids
#  public_subnet       = data.aws_subnets.public.ids
#  vpc_id              = data.aws_vpc.main.id
#  enable_internal_alb = false
#  region              = data.aws_region.current.name
#  enable_ingress = false
#  node_selector       = {}
#  tolerations         = []
#}

resource "tls_private_key" "example" {
  algorithm = "RSA"
}

resource "tls_self_signed_cert" "example" {
  //key_algorithm   = "RSA"
  private_key_pem = tls_private_key.example.private_key_pem

  subject {
    common_name  = "example.com"
    organization = "ACME Examples, Inc"
  }

  validity_period_hours = 12

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "aws_acm_certificate" "cert" {
  private_key      = tls_private_key.example.private_key_pem
  certificate_body = tls_self_signed_cert.example.cert_pem
}

#resource "aws_acm_certificate" "placeholder" {
#  domain_name       = "internal-webhook.local" # Будь-яке ім'я
#  //validation_method = "DNS"
#}

#data "aws_acm_certificate" "primary" {
#  domain   = var.domain_name
#  statuses = ["ISSUED"]
#}

#locals {
#  subdomain_name = "ekslb${var.env_id}.${var.domain_name}"
#}
#
#module "third_certificate" {
#  source  = "terraform-aws-modules/acm/aws"
#  version = "6.3.0"
#
#  domain_name               = local.subdomain_name
#  subject_alternative_names = ["*.${local.subdomain_name}"]
#  zone_id                   = aws_route53_zone.third.zone_id
#
#  wait_for_validation = true
#  validation_method   = "DNS"
#}
#
#resource "aws_route53_zone" "third" {
#  name = local.subdomain_name
#  tags = module.shared.tags
#}
#
#
#
#
#
#module "load_balancer_controller_irsa_role" {
#  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#  version = "~> 5.0"
#
#  role_name                              = "load-balancer-controller"
#  attach_load_balancer_controller_policy = true
#
#  oidc_providers = {
#    ex = {
#      provider_arn               = module.eks.oidc_provider_arn
#      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
#    }
#  }
#}
#
#resource "helm_release" "aws_load_balancer_controller" {
#  name       = "aws-load-balancer-controller"
#  repository = "https://github.io"
#  chart      = "aws-load-balancer-controller"
#  namespace  = "kube-system"
#
#  set = [ {
#    name  = "clusterName"
#    value = module.eks.cluster_name # Назва вашого EKS кластера
#  },
#    {
#    name  = "serviceAccount.create"
#    value = "true"
#  },
#    {
#    name  = "serviceAccount.name"
#    value = "aws-load-balancer-controller"
#  },
#    {
#    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#    value = module.load_balancer_controller_irsa_role.iam_role_arn
#  }]
#}