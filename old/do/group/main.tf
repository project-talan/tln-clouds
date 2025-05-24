module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
  group_id = var.group_id
}

resource "digitalocean_tag" "group" {
  name = var.group_id
}
