data "aws_secretsmanager_secret" "rds_pg_main" {
  arn = var.db_instance_master_user_secret_arn_main
}

data "aws_secretsmanager_secret_version" "rds_pg_main" {
  secret_id = data.aws_secretsmanager_secret.rds_pg_main.id
}

data "aws_secretsmanager_secret_version" "rds_pg_master_password_main" {
  secret_id  = data.aws_secretsmanager_secret.rds_pg_main.id
}

data "aws_secretsmanager_secret" "rds_pg_emteko" {
  arn = var.db_instance_master_user_secret_arn_emteko
}

data "aws_secretsmanager_secret_version" "rds_pg_emteko" {
  secret_id = data.aws_secretsmanager_secret.rds_pg_emteko.id
}

data "aws_secretsmanager_secret_version" "rds_pg_master_password_emteko" {
  secret_id  = data.aws_secretsmanager_secret.rds_pg_emteko.id
}