module "shared" {
  source      = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  group_id    = var.group_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}

resource "digitalocean_project" "project" {
  name        = var.project_id
}

resource "digitalocean_tag" "tags" {
  for_each = module.shared.tags
  name = each.value
}
