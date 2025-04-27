data "digitalocean_vpc" "vpc" {
  name = module.shared.vpc_name
}

data "digitalocean_tags" "list" {
  filter {
    key       = "name"
    values    = [
      module.shared.tags["managed_by"],
      module.shared.tags["org"],
      module.shared.tags["project"],
      var.group_id,
      var.env_id,
    ]
  }
}

data "digitalocean_project" "project" {
  name = var.project_id
}