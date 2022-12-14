terraform {
  required_version = "= 1.3.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.46.0"
    }

    tls = {
      source = "hashicorp/tls"
      version = "3.4.0"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.2.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.16.1"
    }
  }
}

