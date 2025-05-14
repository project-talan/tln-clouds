
locals {
  rds_instance_size               = var.rds_pg.size
  rds_allocated_storage           = var.rds_pg.allocated_storage
  rds_max_allocated_storage       = var.rds_pg.max_allocated_storage
  rds_master_user_password        = var.rds_pg.master_user_password
  rds_engine_version              = var.rds_pg.engine_version
  rds_family                      = var.rds_pg.family
  rds_major_engine_version        = var.rds_pg.major_engine_version
  rds_multi_az                    = var.rds_pg.multi_az
  rds_manage_master_user_password = var.rds_pg.manage_master_user_password
  rds_snapshot_identifier         = var.rds_pg.rds_snapshot_identifier
  rds_backup_schedule             = var.rds_pg.backup_schedule
  rds_backup_lifecycle            = var.rds_pg.backup_lifecycle
}

module "rds" {
  source = "../shared/rds"

  prefix_env                      = module.shared.prefix_env # From app-level shared module
  vpc_id                          = data.aws_vpc.primary.id
  db_subnet_group_name            = module.shared.vpc_name
  node_security_group_id          = data.aws_security_group.node.id
  bastion_security_group_id       = data.aws_security_group.bastion.id
  tags                            = module.shared.tags # From app-level shared module
  rds_manage_master_user_password = local.rds_manage_master_user_password
  rds_pg_db_size                  = local.rds_instance_size
  rds_pg_db_allocated_storage     = local.rds_allocated_storage
  rds_pg_max_allocated_storage    = local.rds_max_allocated_storage
  rds_engine_version              = local.rds_engine_version
  rds_family                      = local.rds_family
  rds_major_engine_version        = local.rds_major_engine_version
  rds_multi_az                    = local.rds_multi_az
  rds_snapshot_identifier         = local.rds_snapshot_identifier
  databases                       = var.databases
  backup_schedule                 = local.rds_backup_schedule
  backup_lifecycle                = local.rds_backup_lifecycle
}
