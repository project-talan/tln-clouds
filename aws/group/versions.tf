terraform {
  required_version = "= 1.14.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.47.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.9.0"
    }    
  }
}
