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

module "db_objects" {
  for_each = local.postgresql_tenants
  source = "../shared/db_objects"

  db_instance_identifier = "${module.shared.prefix_env}-${each.key}-pg-database"

  databases = var.databases
}

variable "databases" {
  description = "A map of databases, their owners and passwords"
  type = map(object({
    owner = string,
    password = string
  }))
}

variable "postgresql" {
  type = list(object({
    tenant = string
    size = string
    allocated_storage = string
    max_allocated_storage = string
    master_user_password = bool
    engine_version = string
    family = string
    major_engine_version = string
    multi_az = bool
    manage_master_user_password = bool
    backup_schedule = string
    backup_lifecycle_delete_after = number
    backup_lifecycle_coldstorage_after = number
    rds_snapshot_identifier = string
    allow_major_version_upgrade = bool
    apply_immediately = bool
  }))
  default = [{
    tenant = "demo"
    size = "db.t4g.micro"
    allocated_storage = "20"
    max_allocated_storage = "30"
    master_user_password = true
    engine_version = "17.4"
    family = "postgres17"
    major_engine_version = "17"
    multi_az = false
    manage_master_user_password = true
    backup_schedule = "cron(0 */2 * * ? *)"
    backup_lifecycle_delete_after = 97
    backup_lifecycle_coldstorage_after = 7
    rds_snapshot_identifier = null
    allow_major_version_upgrade = false
    apply_immediately = false
  }]
}