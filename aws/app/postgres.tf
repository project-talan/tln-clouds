
module "rds" {
  source = "../shared/rds"

  prefix_env                      = module.shared.prefix_env # From app-level shared module
  vpc_id                          = data.aws_vpc.primary.id
  db_subnet_group_name            = module.shared.vpc_name # Assuming vpc_name is suitable for db_subnet_group_name or pass a specific var
  node_security_group_id          = data.aws_security_group.node.id
  bastion_security_group_id       = data.aws_security_group.bastion.id
  tags                            = module.shared.tags # From app-level shared module
  rds_manage_master_user_password = var.rds_manage_master_user_password
  rds_pg_db_size                  = var.rds_pg_db_size
  rds_pg_db_allocated_storage     = var.rds_pg_db_allocated_storage
  rds_pg_max_allocated_storage    = var.rds_pg_max_allocated_storage
  rds_engine_version              = var.rds_engine_version
  rds_family                      = var.rds_family
  rds_major_engine_version        = var.rds_major_engine_version
  rds_multi_az                    = var.rds_multi_az
  databases                       = var.databases
  backup_schedule                 = var.backup_schedule
  backup_lifecycle                = var.backup_lifecycle
}
