
data "digitalocean_vpc" "vpc" {
  name = module.shared.vpc_name
}
