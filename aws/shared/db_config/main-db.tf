provider "postgresql" {
  alias           = "main-db"
  host            = var.main-host
  port            = 5432
  username        = "root" # Master username "root"
  password        = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password_main.secret_string)["password"]
  database        = "postgres" # Connect to the default 'postgres' database for admin tasks
  connect_timeout = 30
  superuser       = false
}

resource "postgresql_role" "main" {
  provider = postgresql.main-db
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}"
  login      = true
  password   = each.value.password

  depends_on = [ aws_vpc_security_group_ingress_rule.allow_bastion_main ]

}

resource "postgresql_database" "main" {
  provider = postgresql.main-db
  for_each = var.databases

  name              = each.key
  owner             = postgresql_role.main[each.key].name
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true

  depends_on = [postgresql_role.main]
}

resource "postgresql_grant" "main_table" {
  provider = postgresql.main-db
  for_each = var.databases

  database    = postgresql_database.main[each.key].name
  role        = postgresql_role.main[each.key].name
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]

  depends_on = [postgresql_database.main]
  lifecycle {
    ignore_changes = [privileges] # To prevent Terraform from revoking manually granted privileges
  }
}

resource "postgresql_grant" "main_schema" {
  provider = postgresql.main-db
  for_each = var.databases

  database    = postgresql_database.main[each.key].name
  role        = postgresql_role.main[each.key].name
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE", "USAGE"] # Grant CREATE and USAGE on public schema

  depends_on = [postgresql_database.main]
  lifecycle {
    ignore_changes = [privileges]
  }
}