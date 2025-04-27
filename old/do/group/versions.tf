terraform {
  required_version = "= 1.7.1"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.34.1"
    }
  }
}
