terraform {
  required_version = "= 1.11.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.96.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.6"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.6"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
  }
}

