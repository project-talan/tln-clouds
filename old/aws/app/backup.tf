module "backup" {
  source = "lgallard/backup/aws"
  version = "0.22.0"

  vault_name = "${module.shared.prefix_env}-pg-vault"

  plan_name = "${module.shared.prefix_env}-pg-backup-plan"

  rules = [
    {
      name     = "db-backup"
      schedule = var.backup_schedule
      lifecycle = {
        delete_after = var.backup_lifecycle
      },
      recovery_point_tags = {
        Environment = module.shared.prefix_env
      }
    },
  ]

  selections = [
    {
      name      = "postgres"
      resources = [module.rds_pg.db_instance_arn]
    },
  ]

  depends_on = [
    module.rds_pg
  ]  
 
  tags = module.shared.tags
}
