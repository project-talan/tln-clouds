module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
  group_id = var.group_id
}

resource "aws_route53_zone" "primary" {
  for_each = var.domains != "" ? toset(split(",", var.domains)) : []

  name = each.key
  tags = module.shared.tags
}

module "root_certificate" {
  for_each = var.domains != "" ? toset(split(",", var.domains)) : []
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = each.key
  subject_alternative_names = ["*.${each.key}"]
  zone_id                   = aws_route53_zone.primary[each.key].zone_id

  wait_for_validation = true
}
