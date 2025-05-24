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
  version = "4.5.0"

  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  zone_id                   = aws_route53_zone.primary.zone_id

  wait_for_validation = true
}
