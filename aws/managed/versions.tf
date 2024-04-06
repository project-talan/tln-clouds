terraform {
  required_version = "= 1.7.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
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
      version = "2.27.0"
    }
  }
}

