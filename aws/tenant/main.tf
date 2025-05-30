module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
  group_id = var.group_id
  env_id = var.env_id
  tenant_id = var.tenant_id
}

module "aws_shared" {
  source = "../shared/database"
  databases = var.tenant_databases
}

resource "aws_route53_record" "record" {
  zone_id  =  var.use_primary_domain ? data.aws_route53_zone.primary.zone_id : data.aws_route53_zone.secondary.zone_id
  name     = var.tenant_id
  type     = "A"

  alias {
    name                   = data.aws_lb.primary.dns_name
    zone_id                = data.aws_lb.primary.zone_id
    evaluate_target_health = false
  }
  depends_on = [
    data.aws_lb.primary
  ]  
}
