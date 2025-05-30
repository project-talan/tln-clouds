terraform {
  required_version = "= 1.11.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
  }
}

