terraform {
  required_version = "= 1.6.3"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.23.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.2"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
  }
}

