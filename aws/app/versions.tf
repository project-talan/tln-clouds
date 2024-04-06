terraform {
  required_version = "= 1.7.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.43.0"
    }
    postgresql = {
      source  = "cyrilgdn/postgresql"
      version = "1.22.0"
    }    
  }
}
