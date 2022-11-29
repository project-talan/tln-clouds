module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  ii_id       = var.ii_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}


data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.18.1"

  name = module.shared.vpc_name
  cidr = "10.0.0.0/16"
  azs  = data.aws_availability_zones.available.names

  # number of private and public subnets should be the same
  # to deploy a load balancer in every AZ
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false
  enable_dns_hostnames   = true
  enable_dns_support     = true
}
