terraform {
  required_version = "= 1.14.8"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.3.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.4.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.2.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.2.0"
    }
  }
}

