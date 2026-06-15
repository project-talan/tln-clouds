module "backup" {
  source  = "lgallard/backup/aws"
  version = "1.9.0"

  depends_on = [module.rds_pg]

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

# this block in version 1.7.1 expect arn already exist, that is way take a look at aws_backup_selection
#  selections = [
#    {
#      name      = "postgres"
#      resources = [module.rds_pg.db_instance_arn]
#    },
#  ]

  tags       = var.tags

}

# 2. element (Selection)
# it will wait ARN db without error
resource "aws_backup_selection" "rds_selection" {
  name         = "${var.prefix_env}-pg-backup-plan"
  iam_role_arn = module.backup.plan_role
  plan_id      = module.backup.plan_id

  resources = [
    module.rds_pg.db_instance_arn
  ]
}
