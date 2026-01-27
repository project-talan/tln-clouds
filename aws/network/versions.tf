terraform {
  required_version = "= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.28.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.1"
    }    
  }
}
