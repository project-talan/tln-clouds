data "aws_secretsmanager_secret" "rds_pg" {
  arn = module.rds_pg.db_instance_master_user_secret_arn
}
data "aws_secretsmanager_secret_version" "rds_pg" {
  secret_id = data.aws_secretsmanager_secret.rds_pg.id
}

data "aws_secretsmanager_secret_version" "rds_pg_master_password" {
  secret_id  = data.aws_secretsmanager_secret.rds_pg.id
}