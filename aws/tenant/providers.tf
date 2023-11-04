provider "aws" {
  default_tags {
    tags = merge(module.shared.tags, { group = var.group_id, env = var.env_id, tenant = var.tenant_id } )
  }
}
