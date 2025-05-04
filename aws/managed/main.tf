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
    aws_authenticator_command_args    = ["--region", "eu-central-1", "eks", "get-token", "--cluster-name", module.shared.k8s_name]
    aws_authenticator_additional_args = []
    aws_authenticator_env_variables   = {}
  })
  eks_managed_node_groups = var.aws_k8s_managed_node_groups
}

module "eks" {
  depends_on = [module.shared]
  source     = "terraform-aws-modules/eks/aws"
  version    = "20.35.0"

  cluster_name    = module.shared.k8s_name
  cluster_version = var.aws_k8s_version
  vpc_id          = data.aws_vpc.main.id
  subnet_ids      = data.aws_subnets.private.ids

  enable_cluster_creator_admin_permissions = true

  # cluster_compute_config = {
  #   enabled    = true
  #   node_pools = ["system"]
  # }

  eks_managed_node_group_defaults = {
    ami_type = "BOTTLEROCKET_x86_64"

    attach_cluster_primary_security_group = true

    # Disabling and using externally provided security groups
    create_security_group = false
  }

  // https://stackoverflow.com/questions/74687452/eks-error-syncing-load-balancer-failed-to-ensure-load-balancer-multiple-tagge
  node_security_group_tags = {
    "kubernetes.io/cluster/${module.shared.k8s_name}" = null
  }

  cluster_security_group_additional_rules = {
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

  eks_managed_node_groups = local.eks_managed_node_groups
  # {
  #   ng1 = {
  #     name = "ng1"

  #     instance_types = [var.aws_k8s_nodes_size]

  #     min_size     = var.aws_k8s_nodes_min
  #     desired_size = var.aws_k8s_nodes_desired
  #     max_size     = var.aws_k8s_nodes_max
  #     //?????? var.aws_k8s_nodes_disk

  #     vpc_security_group_ids = [
  #       aws_security_group.ng1.id
  #     ]
  #   }
  # }
}


