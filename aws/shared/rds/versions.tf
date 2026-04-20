terraform {
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