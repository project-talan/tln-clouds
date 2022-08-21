terraform {
  required_version = "= 1.2.6"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.22.1"
    }
  }
}
