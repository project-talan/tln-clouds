module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
  group_id = var.group_id
  env_id = var.env_id
}

resource "aws_route53_record" "record" {
  for_each = toset(split(",", var.dns_records))
  zone_id  = data.aws_route53_zone.primary.zone_id
  name     = each.key
  type     = "A"

  alias {
    name                   = data.aws_lb.primary.dns_name
    zone_id                = data.aws_lb.primary.zone_id
    evaluate_target_health = false
  }
  depends_on = [
    helm_release.nginx
  ]  
}
