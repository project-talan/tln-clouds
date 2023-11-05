module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  group_id    = var.group_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}

resource "digitalocean_vpc" "vpc" {
  name    = module.shared.vpc_name
  region  = var.do_region
}

resource "digitalocean_tag" "env" {
  name = var.env_id
}
