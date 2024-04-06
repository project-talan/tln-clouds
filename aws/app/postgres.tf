module "rds_pg_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name   = "${module.shared.prefix_env}-pg-database-sg"
  vpc_id = data.aws_vpc.primary.id

  ingress_with_source_security_group_id = [
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = data.aws_security_group.node.id
    },
    {
      rule                     = "postgresql-tcp"
      source_security_group_id = data.aws_security_group.bastion.id
    },
  ]
}

module "rds_pg" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.5.4"

  identifier = "${module.shared.prefix_env}-pg-database"

  engine               = "postgres"
  engine_version       = "15"
  family               = "postgres15"
  major_engine_version = "15"
  instance_class       = var.rds_pg_db_size

  allocated_storage     = 20
  max_allocated_storage = 30

  db_name  = "postgres"
  username = "root"
  port     = 5432

  multi_az = false

  db_subnet_group_name   = module.shared.vpc_name
  vpc_security_group_ids = [module.rds_pg_security_group.security_group_id]

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  #snapshot_identifier = var.rds_snapshot_identifier

  backup_retention_period = 3
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60
  monitoring_role_name                  = "${module.shared.prefix_env}-pg-mntr"
  monitoring_role_use_name_prefix       = true
  monitoring_role_description           = "Description for monitoring role"

  ca_cert_identifier          = "rds-ca-rsa2048-g1"
  manage_master_user_password = true

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "0"
    }
  ]

  tags = module.shared.tags
}

provider "postgresql" {
  host      = module.rds_pg.db_instance_address
  port      = 5432
  scheme    = "awspostgres"
  username  = "root"
  password  = jsondecode(data.aws_secretsmanager_secret_version.rds_pg.secret_string)["password"]
  sslmode   = "disable"
  superuser = false
}

resource "postgresql_role" "this" {
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}" // user-admin
  login      = true
  password   = each.value.password
  depends_on = [module.rds_pg_security_group, module.rds_pg]
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