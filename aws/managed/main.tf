module "shared" {
  source     = "../../shared"
  org_id     = var.org_id
  project_id = var.project_id
  group_id   = var.group_id
  env_id     = var.env_id
}


locals {
  kubeconfig = templatefile("kubeconfig.tpl", {
    kubeconfig_name                   = module.eks.cluster_arn
    endpoint                          = module.eks.cluster_endpoint
    cluster_auth_base64               = module.eks.cluster_certificate_authority_data
    aws_authenticator_command         = "aws"
    aws_authenticator_command_args    = ["eks", "get-token", "--cluster-name", module.shared.k8s_name]
    aws_authenticator_additional_args = []
    aws_authenticator_env_variables   = {}
  })
  eks_managed_node_groups = var.aws_k8s_node_groups
}

module "eks" {
  depends_on = [module.shared]
  source     = "terraform-aws-modules/eks/aws"
  version    = "21.17.1"

  name                     = module.shared.k8s_name
  kubernetes_version       = var.aws_k8s_version
  vpc_id                   = data.aws_vpc.main.id
  subnet_ids               = data.aws_subnets.private.ids
  control_plane_subnet_ids = data.aws_subnets.public.ids

  endpoint_public_access  = false
  endpoint_private_access = true

  enable_cluster_creator_admin_permissions = true # Enable admin permissions for the cluster creator

  enable_irsa                              = true # Enable IAM Roles for Service Accounts (IRSA)

  # cluster_compute_config = {
  #   enabled    = true
  #   node_pools = ["system"]
  # }

  addons = {
    coredns                = {}
    eks-pod-identity-agent = {
      before_compute = true
    }
    kube-proxy             = {}
    vpc-cni                = {
      before_compute = true
    }
    "metrics-server" = {}
  }

  security_group_additional_rules = {
    ingress_bastion_host = {
      description                = "Bastion traffic"
      protocol                   = "tcp"
      from_port                  = 443
      to_port                    = 443
      type                       = "ingress"
      source_node_security_group = false
      source_security_group_id   = data.aws_security_group.bastion.id
    }
  }

  node_security_group_additional_rules = {
    # Allow port 1-1024 inside SG
    ingress_self_80 = {
      description = "Node to node ingress on port 1-1024"
      protocol    = "tcp"
      from_port   = 1
      to_port     = 1024
      type        = "ingress"
      self        = true
    }
  }

  eks_managed_node_groups = local.eks_managed_node_groups

}
