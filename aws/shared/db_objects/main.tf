variable "host" {}
variable "port" {}
variable "username" {}
variable "password" {}
variable "databases" {}


provider "postgresql" {
  host     = var.host
  port     = var.port
  username = var.username
  password = var.password
  database = "postgres"
}

resource "postgresql_role" "this" {
#  provider = postgresql.rds_admin
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}"
  login      = true
  password   = each.value.password
#  depends_on = [module.rds_pg, resource.aws_vpc_security_group_ingress_rule.allow_bastion]
}

resource "postgresql_database" "this" {
#  provider = postgresql.rds_admin
  for_each = var.databases

  name              = each.key
  owner             = postgresql_role.this[each.key].name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true

  depends_on = [postgresql_role.this]
}

resource "postgresql_grant" "this_table" {
#  provider = postgresql.rds_admin
  for_each = var.databases

  database    = postgresql_database.this[each.key].name
  role        = postgresql_role.this[each.key].name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]

  depends_on = [postgresql_database.this]
  lifecycle {
    ignore_changes = [privileges] # To prevent Terraform from revoking manually granted privileges
  }
}

resource "postgresql_grant" "this_schema" {
#  provider = postgresql.rds_admin
  for_each = var.databases

  database    = postgresql_database.this[each.key].name
  role        = postgresql_role.this[each.key].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"] # Grant CREATE and USAGE on public schema

  depends_on = [postgresql_database.this]
  lifecycle {
    ignore_changes = [privileges]
  }
}