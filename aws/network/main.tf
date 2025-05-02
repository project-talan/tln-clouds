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
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names

  private_subnets  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets   = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  database_subnets = ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]

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

  resources_prefix = "${module.shared.prefix_env}-bastion"
  files_prefix     = "${var.group_id}-${var.env_id}-bastion"
  vpc_id           = module.vpc.vpc_id
  subnet_id        = module.vpc.public_subnets[0] # Replace with your actual public subnet ID source
  instance_type    = var.bastion_instance_type
  user_data        = var.bastion_user_data
  tags             = module.shared.tags

}



