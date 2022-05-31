
data "digitalocean_vpc" "vpc" {
  name = module.shared.vpc_name
}

data "digitalocean_tags" "list" {
  filter {
    key       = "name"
    values    = [module.shared.tags["project"], module.shared.tags["infrastructure_instance"], module.shared.tags["managed_by"]]
  }
}