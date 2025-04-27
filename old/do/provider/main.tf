module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
}

resource "digitalocean_project" "project" {
  name = var.project_id
}

resource "digitalocean_tag" "tags" {
  for_each = module.shared.tags
  name = each.value
}

resource "digitalocean_container_registry" "primary" {
  count = var.registry != "" ? 1 : 0 
  name = var.registry
  subscription_tier_slug = "starter"
  region = var.do_region
}