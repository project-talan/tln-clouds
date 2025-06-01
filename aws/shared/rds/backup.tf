module "backup" {
  source  = "lgallard/backup/aws"
  version = "0.23.8"

  vault_name = "${var.prefix_env}-pg-vault"
  plan_name  = "${var.prefix_env}-pg-backup-plan"

  rules = [
    {
      name     = "${var.prefix_env}-db-backup"
      schedule = var.backup_schedule # e.g., "cron(0 5 * * ? *)"
      lifecycle = {
        # Note: lifecycle_delete_after cannot be less than 90 days apart from lifecycle_coldstorage_after
        delete_after = var.backup_lifecycle_delete_after # e.g., 97 days
        cold_storage_after = var.backup_lifecycle_coldstorage_after # e.g., 7 days
      },
      recovery_point_tags = {
        Environment = var.prefix_env
      }
    },
  ]

  selections = [
    {
      name      = "postgres"
      resources = [module.rds_pg.db_instance_arn]
    },
  ]

  depends_on = [module.rds_pg]
  tags       = var.tags
}
