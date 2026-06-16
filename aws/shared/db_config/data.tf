data "aws_db_instance" "main" {
  db_instance_identifier = var.db_instance_identifier_main
}

data "aws_secretsmanager_secret" "rds_pg_main" {
  arn = data.aws_db_instance.main.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_pg_main" {
  secret_id = data.aws_secretsmanager_secret.rds_pg_main.id
}

data "aws_db_instance" "emteko" {
  db_instance_identifier = var.db_instance_identifier_emteko
}

data "aws_secretsmanager_secret" "rds_pg_emteko" {
  arn = data.aws_db_instance.emteko.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_pg_emteko" {
  secret_id = data.aws_secretsmanager_secret.rds_pg_emteko.id
}