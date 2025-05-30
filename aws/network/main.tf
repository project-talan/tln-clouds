module "shared" {
  source     = "../../shared"
  org_id     = var.org_id
  project_id = var.project_id
  group_id   = var.group_id
  env_id     = var.env_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.21.0"

  name = module.shared.vpc_name
  cidr = var.vpc_cidr
  azs  = data.aws_availability_zones.available.names

  private_subnets  = var.private_subnets
  public_subnets   = var.public_subnets
  database_subnets = var.database_subnets

  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true

  public_subnet_tags = merge(module.shared.public_subnet_tags, {
    "kubernetes.io/cluster/${module.shared.k8s_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
  })

  private_subnet_tags = merge(module.shared.private_subnet_tags, {
    "kubernetes.io/cluster/${module.shared.k8s_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  })

  tags = {
    "kubernetes.io/cluster/${module.shared.k8s_name}" = "shared"
  }
}

module "bastion" {
  source = "../shared/jumpserver"
  use_default_vpc  = false

  resources_prefix = "${module.shared.prefix_env}-bastion"
  files_prefix     = "${var.group_id}-${var.env_id}-bastion"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets[0]
  instance_type    = var.bastion_instance_type
  custom_packages  = var.bastion_custom_packages
  tags             = module.shared.tags
}


