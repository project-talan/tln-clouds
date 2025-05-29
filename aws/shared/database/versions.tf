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
  }
}
