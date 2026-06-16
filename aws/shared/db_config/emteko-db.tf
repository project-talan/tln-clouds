provider "postgresql" {
  alias           = "emteko-db"
  host            = var.emteko-host
  port            = 5432
  username        = "root" # Master username "root"
  password        = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]
  database        = "postgres" # Connect to the default 'postgres' database for admin tasks
  connect_timeout = 30
  superuser       = false
}

resource "postgresql_role" "emteko" {
  provider = postgresql.emteko-db
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}"
  login      = true
  password   = each.value.password

}

resource "postgresql_database" "emteko" {
  provider = postgresql.emteko-db
  for_each = var.databases

  name              = each.key
  owner             = postgresql_role.emteko[each.key].name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true

  depends_on = [postgresql_role.emteko]
}

resource "postgresql_grant" "emteko_table" {
  provider = postgresql.emteko-db
  for_each = var.databases

  database    = postgresql_database.emteko[each.key].name
  role        = postgresql_role.emteko[each.key].name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]

  depends_on = [postgresql_database.emteko]
  lifecycle {
    ignore_changes = [privileges] # To prevent Terraform from revoking manually granted privileges
  }
}

resource "postgresql_grant" "emteko_schema" {
  provider = postgresql.emteko-db
  for_each = var.databases

  database    = postgresql_database.emteko[each.key].name
  role        = postgresql_role.emteko[each.key].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"] # Grant CREATE and USAGE on public schema

  depends_on = [postgresql_database.emteko]
  lifecycle {
    ignore_changes = [privileges]
  }
}