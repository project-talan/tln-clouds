
locals {
  postgresql_tenants = {
    for db in var.postgresql : db.tenant => {
      rds_instance_size                      = db.size
      rds_allocated_storage                  = db.allocated_storage
      rds_max_allocated_storage              = db.max_allocated_storage
      rds_master_user_password               = db.master_user_password
      rds_engine_version                     = db.engine_version
      rds_family                             = db.family
      rds_major_engine_version               = db.major_engine_version
      rds_multi_az                           = db.multi_az
      rds_manage_master_user_password        = db.manage_master_user_password
      rds_snapshot_identifier                = db.rds_snapshot_identifier
      rds_backup_schedule                    = db.backup_schedule
      rds_backup_lifecycle_delete_after      = db.backup_lifecycle_delete_after
      rds_backup_lifecycle_coldstorage_after = db.backup_lifecycle_coldstorage_after
      rds_allow_major_version_upgrade        = db.allow_major_version_upgrade
      rds_apply_immediately                  = db.apply_immediately
    }
  }
}

module "rds" {
  for_each = local.postgresql_tenants
  source = "../shared/rds"

  prefix_env                         = "${module.shared.prefix_env}-${each.key}" # From app-level shared module
  vpc_id                             = data.aws_vpc.primary.id
  db_subnet_group_name               = module.shared.vpc_name
  node_security_group_id             = data.aws_security_group.node.id
  bastion_security_group_id          = data.aws_security_group.bastion.id
  tags                               = module.shared.tags # From app-level shared module

  rds_manage_master_user_password    = each.value.rds_manage_master_user_password
  rds_pg_db_size                     = each.value.rds_instance_size
  rds_pg_db_allocated_storage        = each.value.rds_allocated_storage
  rds_pg_max_allocated_storage       = each.value.rds_max_allocated_storage
  rds_engine_version                 = each.value.rds_engine_version
  rds_family                         = each.value.rds_family
  rds_major_engine_version           = each.value.rds_major_engine_version
  rds_multi_az                       = each.value.rds_multi_az
  rds_snapshot_identifier            = each.value.rds_snapshot_identifier
  databases                          = var.databases
  backup_schedule                    = each.value.rds_backup_schedule
  backup_lifecycle_delete_after      = each.value.rds_backup_lifecycle_delete_after
  backup_lifecycle_coldstorage_after = each.value.rds_backup_lifecycle_coldstorage_after
  rds_allow_major_version_upgrade    = each.value.rds_allow_major_version_upgrade
  rds_apply_immediately              = each.value.rds_apply_immediately
}

#module "db_config" {
#  source = "../shared/db_config"
#
#  db_instance_identifier_main   = "${module.shared.prefix_env}-demo-pg-databas"
#  db_instance_identifier_emteko = "${module.shared.prefix_env}-emteko-pg-databas"
#  main-host                     = module.rds["demo"].db_instance_address
#  emteko-host                   = module.rds["emteko"].db_instance_address
#
#  databases = var.databases
#}
