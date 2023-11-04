provider "aws" {
  default_tags {
    tags = merge(module.shared.tags, { group = var.group_id } )
  }
}
