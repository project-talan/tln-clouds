module "backup" {
  source  = "lgallard/backup/aws"
  version = "0.23.8"

  vault_name = "${var.prefix_env}-pg-vault"
  plan_name  = "${var.prefix_env}-pg-backup-plan"

  rules = [
    {
      name     = "db-backup"
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
  selection_tags = [
    {
      Environment = var.prefix_env
    }
  ]

  depends_on = [module.rds_pg]
  tags       = var.tags
}
