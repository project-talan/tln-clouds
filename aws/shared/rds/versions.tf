terraform {
  required_version = "= 1.11.4"
  required_providers {
    postgresql = { 
      source = "cyrilgdn/postgresql"
      version = "1.24.0"
    }
  }
}