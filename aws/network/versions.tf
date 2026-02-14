terraform {
  required_version = "= 1.14.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.32.1"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.6.2"
    }    
  }
}
