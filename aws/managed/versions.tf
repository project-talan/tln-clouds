terraform {
  required_version = "= 1.14.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.1.0"
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
      source = "hashicorp/helm"
      version = "3.1.1"
    }

  }
}

