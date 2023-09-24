terraform {
  required_version = "= 1.5.7"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.30.0"
    }
  }
}
