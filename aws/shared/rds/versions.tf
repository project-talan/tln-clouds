terraform {
  required_version = "= 1.14.3"
  required_providers {
    postgresql = { 
      source = "cyrilgdn/postgresql"
      version = "1.26.0"
    }
  }
}