module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.0"

  name = module.shared.vpc_name
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

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
