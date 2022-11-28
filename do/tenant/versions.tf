terraform {
  required_version = "= 1.3.5"

  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.24.0"
    }
  }
}
