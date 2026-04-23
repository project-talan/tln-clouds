# 1. IAM role only (required for access permissions)
module "lb_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts"
  version = "6.4"

  name                           = "${module.shared.k8s_name}-lbcr"
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
  depends_on = [module.lb_controller_irsa_role]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  # Equvalent to 'helm upgrade --install'
  upgrade_install = true

  version    = "3.2.1"

  set = [
    {
      name  = "clusterName"
      value = "${module.shared.k8s_name}"
    },
    {
      name  = "replicaCount"
      value = "1"
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
      value = module.lb_controller_irsa_role.arn
    },
    {
      name  = "vpcId"
      value = data.aws_vpc.primary.id
    },
    {
      name  = "region"
      value = data.aws_region.current.id # change to you region
    }
  ]
}

# 2. timer for delete
resource "time_sleep" "wait_after_nginx" {
  # activate after the load balancer controller release so its destruction is delayed
  depends_on = [helm_release.aws_load_balancer_controller]

  # wait 320 seconds before deleting the load balancer controller
  destroy_duration = "320s"
}