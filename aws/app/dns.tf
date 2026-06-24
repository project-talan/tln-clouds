
locals {
  subdomain_name = "${var.env_id}.${var.domain_name}"
}

resource "aws_route53_zone" "secondary" {
  name = local.subdomain_name
  tags = module.shared.tags
}

resource "aws_route53_record" "ns" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = local.subdomain_name
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.secondary.name_servers
}

resource "aws_route53_record" "caa_record" {
  zone_id = aws_route53_zone.secondary.zone_id # ID your Hosted Zone
  name    = local.subdomain_name
  type    = "CAA"
  ttl     = "3600"

  records = [
    "0 issue \"amazon.com\"",          # Allow AWS ACM
    "0 issuewild \"amazonses.com\"",   # Allow Wildcard для SES
    "0 iodef \"mailto:security@${var.domain_name}\"" # Where to send letter about issue
  ]
}

module "secondary_certificate" {
  source  = "terraform-aws-modules/acm/aws"
  version = "6.3.0"

  domain_name               = local.subdomain_name
  subject_alternative_names = ["*.${local.subdomain_name}"]
  zone_id                   = aws_route53_zone.secondary.zone_id

  wait_for_validation = true
  validation_method   = "DNS"
}

resource "aws_route53_record" "record" {
  for_each = toset(split(",", var.dns_records))
  zone_id  =  var.use_primary_domain ? data.aws_route53_zone.primary.zone_id : aws_route53_zone.secondary.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = data.aws_lb.primary.dns_name
    zone_id                = data.aws_lb.primary.zone_id
    evaluate_target_health = false
  }
  depends_on = [
    helm_release.nginx,
    data.aws_lb.primary
  ]  
}
