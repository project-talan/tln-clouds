terraform {
  required_version = "= 1.7.1"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.34.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.3"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.25.2"
    }
  }
}

