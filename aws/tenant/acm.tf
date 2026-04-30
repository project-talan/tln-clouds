/*
locals {
  tenant_prefix        = var.use_primary_domain ? var.tenant_id : "${var.tenant_id}.${var.env_id}"
  static_domain_prefix = "${var.static_subdomain}.${local.tenant_prefix}"
  static_domain_name   = "${local.static_domain_prefix}.${var.domain_name}"

  zone_id = var.use_primary_domain ? data.aws_route53_zone.primary.zone_id : data.aws_route53_zone.secondary.zone_id
}

module "acm" {
  providers = {
    aws = aws.us_east_1
  }
  source      = "../shared/acm"
  domain_name = local.static_domain_name
  zone_id     = local.zone_id
}
*/