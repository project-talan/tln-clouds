provider "aws" {
  default_tags {
    tags = module.shared.tags
  }
}
