terraform {
  required_version = "= 1.11.4"
  required_providers {
    postgresql = { 
      source = "cyrilgdn/postgresql"
      version = "1.26.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}