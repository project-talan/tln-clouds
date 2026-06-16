provider "postgresql" {
  alias           = "main-db"
  host            = var.main-host
  port            = 5432
  username        = "root" # Master username "root"
  password        = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_main.secret_string)["password"]
  database        = "postgres" # Connect to the default 'postgres' database for admin tasks
  connect_timeout = 30
  superuser       = false
}

resource "postgresql_role" "this" {
  provider = postgresql.main-db
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}"
  login      = true
  password   = each.value.password

}

resource "postgresql_database" "this" {
  provider = postgresql.main-db
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
  provider = postgresql.main-db
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
  provider = postgresql.main-db
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