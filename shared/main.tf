variable "org_id" {
  type = string
}
variable "project_id" {
  type = string
}
variable "ii_id" {
  type = string
}
variable "env_id" {
  type = string
}
variable "tenant_id" {
  type = string
}

locals {
  prefix = "${var.project_id}-${var.ii_id}"
}

output "prefix" {
  value = local.prefix
}

output "tags" {
  value = {
    Org         = var.org_id
    Proj        = var.project_id
    II          = var.ii_id
    Env         = var.env_id
    ManagedBy   = "terraform"
  }
}

output "vpc_name" {
  value = "${local.prefix}-vpc"
}
output "private_subnet_tags" {
  value = { Type = "private" }
}
output "public_subnet_tags" {
  value = { Type = "public" }
}

output "k8s_name" {
  value = "${local.prefix}-k8s"
}
output "k8s_pool_name" {
  value = "${local.prefix}-k8s-pool"
}
output "k8s_config_name" {
  value = ".kube.config.${var.ii_id}"
}
