
data "digitalocean_vpc" "vpc" {
  name = module.shared.vpc_name
}

data "digitalocean_tags" "list" {
  filter {
    key       = "name"
    values    = [
      module.shared.tags["org"],
      module.shared.tags["proj"],
      module.shared.tags["ii"],
      module.shared.tags["env"],
      module.shared.tags["proj"],
      module.shared.tags["managed_by"]
    ]
  }
}
