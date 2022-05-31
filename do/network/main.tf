module "shared" {
  source        = "../../shared"
  project_name  = var.project_name
  ii_name       = var.ii_name
  env_name      = var.env_name
  tenant_name   = var.tenant_name
}


resource "digitalocean_vpc" "vpc" {
  name    = module.shared.vpc_name
  region  = var.do_region
}

resource "digitalocean_tag" "tags" {
  for_each = module.shared.tags
  name = each.value
}

/*
resource "digitalocean_droplet" "web" {
  image   = "ubuntu-18-04-x64"
  name    = "web-1"
  region  = var.do_region
  size    = "s-1vcpu-1gb"
  tags    = [digitalocean_tag.tags["project"].id, digitalocean_tag.tags["infrastructure_instance"].id, digitalocean_tag.tags["environment"].id, digitalocean_tag.tags["managed_by"].id]

  depends_on = [digitalocean_tag.tags]
}
*/