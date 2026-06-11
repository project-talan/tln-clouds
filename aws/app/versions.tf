terraform {
  required_version = "= 1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.26.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.14.0"
    }
  }
}
