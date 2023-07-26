terraform {
  required_version = "= 1.5.3"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.29.0"
    }
  }
}
