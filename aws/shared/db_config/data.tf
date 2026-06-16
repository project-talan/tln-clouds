data "aws_db_instance" "this" {
  db_instance_identifier = var.db_instance_identifier
}

data "aws_secretsmanager_secret" "rds_pg" {
  arn = data.aws_db_instance.this.master_user_secret[0].secret_arn
}

data "aws_secretsmanager_secret_version" "rds_pg" {
  secret_id = data.aws_secretsmanager_secret.rds_pg.id
}