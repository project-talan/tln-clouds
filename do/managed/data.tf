
data "digitalocean_vpc" "vpc" {
  name = module.shared.vpc_name
}

data "digitalocean_tags" "list" {
  filter {
    key       = "name"
    values    = [
      module.shared.tags["ManagedBy"],
      module.shared.tags["Org"],
      module.shared.tags["Proj"],
      module.shared.tags["Env"],
/*
      module.shared.tags["Tenant"],
*/
    ]
  }
}
