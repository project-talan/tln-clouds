module "backup" {
  source  = "lgallard/backup/aws"
  version = "0.22.0"

  vault_name = "${var.prefix_env}-pg-vault"
  plan_name  = "${var.prefix_env}-pg-backup-plan"

  rules = [
    {
      name     = "db-backup"
      schedule = var.backup_schedule # e.g., "cron(0 5 * * ? *)"
      lifecycle = {
        delete_after = var.backup_lifecycle # e.g., 35 days
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