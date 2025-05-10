module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
  group_id = var.group_id
}

resource "aws_route53_zone" "primary" {
  name = var.domain_name
  tags = module.shared.tags
}

module "root_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.1.1"

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  zone_id                   = aws_route53_zone.primary.zone_id

  wait_for_validation = true
  validation_method   = "DNS"
}

/* # Uncomment to provision a jumpbox for secure ETL across multiple environments
module "jumpbox" {
  source = "../shared/jumpserver"

  resources_prefix = "${module.shared.prefix_env}-jumpbox"
  files_prefix     = "${var.group_id}-${var.env_id}-jumpbox"
  ????? vpc_id           = module.vpc.vpc_id
  ????? subnet_id        = module.vpc.public_subnets[0]
  instance_type    = var.jumpbox_instance_type
  custom_packages  = var.jumpbox_custom_packages
  tags             = module.shared.tags
}
*/