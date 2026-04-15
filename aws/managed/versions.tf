terraform {
  required_version = "= 1.11.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.39.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.2.1"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.7"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "3.0.1"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "3.1.1"
    }
  }
}

