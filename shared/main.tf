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
    org         = var.org_id
    proj        = var.project_id
    ii          = var.ii_id
    env         = var.env_id
    managed_by  = "terraform"
  }
}

output "vpc_name" {
  value = "${local.prefix}-vpc"
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
