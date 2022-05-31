variable "project_name" {
  type = string
}
variable "ii_name" {
  type = string
}
variable "env_name" {
  type = string
}
variable "tenant_name" {
  type = string
}

locals {
  prefix = "${var.project_name}-${var.ii_name}"
}

output "prefix" {
  value = local.prefix
}

output "tags" {
  value = {
    project                 = var.project_name
    infrastructure_instance = var.ii_name
    environment             = var.env_name
    managed_by              = "terraform"
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
  value = ".kube.config.${var.ii_name}"
}
