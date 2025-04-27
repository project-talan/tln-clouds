variable "org_id" {
  type = string
}
variable "project_id" {
  type = string
}
variable "group_id" {
  type = string
  default = ""
}
variable "env_id" {
  type = string
  default = ""
}
variable "tenant_id" {
  type = string
  default = ""
}

locals {
  prefix_project = "${var.project_id}"
  prefix_group = "${var.project_id}-${var.group_id}"
  prefix_env = "${var.project_id}-${var.group_id}-${var.env_id}"
  prefix_tenant = "${var.project_id}-${var.group_id}-${var.env_id}-${var.tenant_id}"
}

output "prefix_project" {
  value = local.prefix_project
}
output "prefix_group" {
  value = local.prefix_group
}
output "prefix_env" {
  value = local.prefix_env
}
output "prefix_tenant" {
  value = local.prefix_tenant
}

output "tags" {
  value = {
    managed_by  = "terraform"
    org         = var.org_id
    project     = var.project_id
  }
}

output "vpc_name" {
  value = "${local.prefix_env}-vpc"
}
output "private_subnet_tags" {
  value = { Type = "private" }
}
output "public_subnet_tags" {
  value = { Type = "public" }
}

output "k8s_name" {
  value = "${local.prefix_env}-k8s"
}
output "k8s_pool_name" {
  value = "${local.prefix_env}-k8s-pool"
}
output "k8s_config_name" {
  value = ".kube.config.${var.env_id}"
}
