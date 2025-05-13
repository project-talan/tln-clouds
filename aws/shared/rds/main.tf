resource "aws_security_group" "postgres_sg" {
  name        = "${var.prefix_env}-sg"
  description = "Allow connection to Postgres server"
  vpc_id      = var.vpc_id
  lifecycle {
    create_before_destroy = true
  }
  timeouts {
    create = "10m"
    delete = "2m"
  }
  tags = var.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_bastion" {
  security_group_id            = aws_security_group.postgres_sg.id
  referenced_security_group_id = var.bastion_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow Postgresql traffic from bastion"
  lifecycle {
    create_before_destroy = true
  }

  tags = var.tags
}
resource "aws_vpc_security_group_ingress_rule" "allow_k8s_nodes" {
  security_group_id            = aws_security_group.postgres_sg.id
  referenced_security_group_id = var.node_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
  description                  = "Allow Postgresql traffic from kubernetes nodes"
  lifecycle {
    create_before_destroy = true
  }
  tags = var.tags
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  security_group_id = aws_security_group.postgres_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols
  description       = "Allow all outbound traffic"
  tags              = var.tags
  lifecycle {
    create_before_destroy = true
  }
}

module "rds_pg" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.5.4"

  identifier = "${var.prefix_env}-pg-database"

  engine               = "postgres"
  engine_version       = var.rds_engine_version
  family               = var.rds_family
  major_engine_version = var.rds_major_engine_version
  instance_class       = var.rds_pg_db_size

  allocated_storage     = var.rds_pg_db_allocated_storage
  max_allocated_storage = var.rds_pg_max_allocated_storage

  db_name  = "postgres" # Default database
  username = "root"     # Master username
  port     = 5432

  multi_az = var.rds_multi_az

  db_subnet_group_name   = var.db_subnet_group_name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  publicly_accessible    = false
  snapshot_identifier    = var.rds_snapshot_identifier

  maintenance_window              = "Mon:00:00-Mon:03:00"
  backup_window                   = "03:00-06:00"
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  create_cloudwatch_log_group     = true

  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot     = var.rds_skip_final_snapshot
  deletion_protection     = var.rds_deletion_protection

  performance_insights_enabled          = var.rds_performance_insights_enabled
  performance_insights_retention_period = var.rds_performance_insights_retention_period
  create_monitoring_role                = true
  monitoring_interval                   = var.rds_monitoring_interval
  monitoring_role_name                  = "${var.prefix_env}-pg-mntr"
  monitoring_role_use_name_prefix       = true # To avoid conflict if name exists
  monitoring_role_description           = "Monitoring role for RDS instance ${var.prefix_env}-pg-database"


  ca_cert_identifier          = var.rds_ca_cert_identifier
  manage_master_user_password = var.rds_manage_master_user_password # RDS manages the master password in Secrets Manager

  parameters = [
    {
      name  = "rds.force_ssl"
      value = "0" # Review this setting for production environments
    }
  ]

  tags = var.tags
}
data "aws_secretsmanager_secret" "rds_pg" {
  arn = module.rds_pg.db_instance_master_user_secret_arn
}
data "aws_secretsmanager_secret_version" "rds_pg" {
  secret_id = data.aws_secretsmanager_secret.rds_pg.id
}

data "aws_secretsmanager_secret_version" "rds_pg_master_password" {
  depends_on = [module.rds_pg]
  secret_id  = data.aws_secretsmanager_secret.rds_pg.id
}

provider "postgresql" {
  alias           = "rds_admin"
  host            = module.rds_pg.db_instance_address
  port            = module.rds_pg.db_instance_port
  username        = module.rds_pg.db_instance_username # Master username "root"
  password        = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]
  database        = "postgres" # Connect to the default 'postgres' database for admin tasks
  connect_timeout = 30
  superuser       = false
}

resource "postgresql_role" "this" {
  provider = postgresql.rds_admin
  for_each = var.databases

  name       = "${each.key}-${each.value.owner}"
  login      = true
  password   = each.value.password
  depends_on = [module.rds_pg] # 
}

resource "postgresql_database" "this" {
  provider = postgresql.rds_admin
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
  provider = postgresql.rds_admin
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
  provider = postgresql.rds_admin
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
