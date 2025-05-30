resource "postgresql_role" "this" {
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}" // user-admin
  login      = true
  password   = each.value.password
}

resource "postgresql_database" "this" {
  for_each = var.databases

  name              = each.key // user
  owner             = "${each.key}-${each.value.owner}" // user-admin
  template          = "template0"
  lc_collate        = "en_US.UTF-8"
  connection_limit  = -1
  allow_connections = true

  depends_on = [postgresql_role.this]
}

resource "postgresql_grant" "this_table" {
  for_each = var.databases

  database    = each.key // user
  role        = "${each.key}-${each.value.owner}" // user-admin
  schema      = "public"
  object_type = "table"
  privileges  = ["ALL"]

  depends_on = [postgresql_database.this]
  lifecycle {
    ignore_changes = [privileges]
  }
}

resource "postgresql_grant" "this_schema" {
  for_each = var.databases

  database    = each.key
  role        = "${each.key}-${each.value.owner}" // user-admin
  schema      = "public"
  object_type = "schema"
  privileges  = ["CREATE"]

  depends_on = [postgresql_database.this]
  lifecycle {
    ignore_changes = [privileges]
  }
}
