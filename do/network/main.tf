module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  ii_id       = var.ii_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}

resource "digitalocean_vpc" "vpc" {
  name    = module.shared.vpc_name
  region  = var.do_region
}

resource "digitalocean_tag" "tags" {
  for_each = module.shared.tags
  name = each.value
}
