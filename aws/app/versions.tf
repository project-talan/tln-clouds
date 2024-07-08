terraform {
  required_version = "= 1.9.1"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.27.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.13.0"
    }
  }
}
