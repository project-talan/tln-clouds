locals {
  cluster_name                       = module.shared.k8s_name
  deploy_cluster_autoscaler          = var.cluster_autoscaler.enabled
  autoscaler_helm_chart_version     = var.cluster_autoscaler.helm_chart_version
  autoscaler_priority_class_name    = var.cluster_autoscaler.priority_class_name
  autoscaler_helm_release_name      = var.cluster_autoscaler.helm_release_name
  autoscaler_helm_release_namespace = var.cluster_autoscaler.helm_release_namespace
  autoscaler_serviceaccount_name    = var.cluster_autoscaler.serviceaccount_name
  autoscaler_extra_args             = var.cluster_autoscaler.extra_args
}


resource "aws_iam_role" "eks_autoscaling" {
  count              = local.deploy_cluster_autoscaler == true ? 1 : 0
  name               = "${local.cluster_name}-eks-autoscaling-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster-autoscaler_trust_policy[0].json
}

resource "aws_iam_role_policy" "cluster-autoscaling-policy" {
  count  = local.deploy_cluster_autoscaler == true ? 1 : 0
  name   = "${local.cluster_name}-cluster-autoscaling-policy"
  role   = aws_iam_role.eks_autoscaling[0].id
  policy = data.aws_iam_policy_document.eks_cluster-autoscaler_policy[0].json
}

resource "helm_release" "cluster_autoscaler" {
  depends_on = [module.eks]
  count      = local.deploy_cluster_autoscaler == true ? 1 : 0
  name       = local.autoscaler_helm_release_name
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  namespace  = local.autoscaler_helm_release_namespace
  version    = local.autoscaler_helm_chart_version
  timeout    = 300
  values = [
    yamlencode({
      awsRegion     = data.aws_region.current.name
      cloudProvider = "aws"
      autoDiscovery = {
        clusterName = local.cluster_name
      }
      priorityClassName = local.autoscaler_priority_class_name
      replicaCount      = 2
      tolerations       = []
      affinity          = []
      podDisruptionBudget = {
        maxUnavailable = 1
      }
      rbac = {
        serviceAccount = {
          name = local.autoscaler_serviceaccount_name
          annotations = {
            "eks.amazonaws.com/role-arn" = aws_iam_role.eks_autoscaling[0].arn
          }
        }
      }
    })
  ]
  dynamic "set" {
    for_each = local.autoscaler_extra_args
    content {
      name  = "extraArgs.${set.key}"
      value = set.value
    }
  }
}


data "aws_iam_policy_document" "eks_cluster-autoscaler_trust_policy" {
  count = local.deploy_cluster_autoscaler == true ? 1 : 0
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [module.eks.oidc_provider_arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${module.eks.oidc_provider}:sub"

      values = [
        "system:serviceaccount:${local.autoscaler_helm_release_namespace}:${local.autoscaler_serviceaccount_name}",
      ]
    }

    effect = "Allow"
  }
}
data "aws_iam_policy_document" "eks_cluster-autoscaler_policy" {
  count = local.deploy_cluster_autoscaler == true ? 1 : 0
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeTags",
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup",
      "ec2:Describe*",
      "ec2:DescribeVolumeAttachments",
      "ec2:DescribeVolumes",
      "eks:DescribeNodegroup",
    ]
    resources = ["*"]
  }
}
