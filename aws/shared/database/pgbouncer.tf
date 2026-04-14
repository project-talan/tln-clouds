#data "aws_db_instance" "existing_rds" {
#  db_instance_identifier = var.db_instance_identifier
#}
#
#locals {
#  # Витягуємо адресу хоста
#  rds_host = data.aws_db_instance.existing_rds.address
#  # Порт (зазвичай 5432)
#  rds_port = data.aws_db_instance.existing_rds.port
#}
#
##data "aws_secretsmanager_secret" "rds_pg" {
##  count = data.aws_db_instance.existing_rds != null ? 1 : 0
##  arn = data.aws_db_instance.existing_rds.master_user_secret[0].secret_arn
##}
##
##data "aws_secretsmanager_secret_version" "rds_pg" {
##  count     = length(data.aws_secretsmanager_secret.rds_pg)
##  secret_id = data.aws_secretsmanager_secret.rds_pg[0].id
##}
##
##data "aws_secretsmanager_secret_version" "rds_pg_master_password" {
##  count      = length(data.aws_secretsmanager_secret.rds_pg)
##  secret_id  = data.aws_secretsmanager_secret.rds_pg[0].id
##}
##
##locals {
##  # one() поверне перший елемент або null, якщо список порожній
##  secret_data = one(data.aws_secretsmanager_secret_version.rds_pg_master_password)
##  db_password = local.secret_data != null ? jsondecode(local.secret_data.secret_string)["password"] : null
##}
#
#data "aws_db_instance" "this" {
#  db_instance_identifier = var.db_instance_identifier
#}
#
#data "aws_secretsmanager_secret" "rds_pg" {
#  arn = data.aws_db_instance.this.master_user_secret[0].secret_arn
#}
#
#data "aws_secretsmanager_secret_version" "rds_pg" {
#  secret_id = data.aws_secretsmanager_secret.rds_pg.id
#}
#
#resource "helm_release" "pgbouncer" {
#  name             = "pgbouncer"
#  repository       = "https://icoretech.github.io/helm"
#  chart            = "pgbouncer"
#  namespace        = "database-tenant"
#  create_namespace = true
#  cleanup_on_fail  = true
#
#  # Forces Kubernetes to recreate pods if the configuration changes.
#  force_update     = true
#  recreate_pods    = true
#  replace          = true
#
#  version          = "2.1.1"
#
#
##  set = {
##    name  = "config.userlist"
##    # We use join to convert a list into a SINGLE string with newlines. \n
##    value = join("\n", [
##      for name, info in var.databases : "\"${info.owner}\" \"${info.password}\""
##    ])
##  }
##  set = [
##    for name, data in var.databases : {
##      name  = "config.databases.${name}"
##      value = "host=${module.rds_pg.db_instance_address} port=5432 dbname=${name} user=${data.owner} password=${data.password}"
##      }
##  ]
#
##  value = "postgres://${data.owner}:${data.password}@${module.rds_pg.db_instance_address}:5432/${name}"
#
#  # Example of passing custom configuration
#  values = [
#    file("${path.module}/chart/pgbouncer/pgbouncer-values.yaml"),
#
#    yamlencode({
#      config = {
#        auth_type = "md5"
#        server_tls_sslmode = "require"
#        # Retrieving the password from AWS Secrets Manager or a variable.
#        adminPassword = jsondecode(data.aws_secretsmanager_secret_version.rds_pg.secret_string)["password"]
#        databases = {
#          for name, data in var.databases : name => {
#            host     = local.rds_host
#            port     = 5432
#            user     = "${name}-${data.owner}"
#            password = data.password
#            dbname   = name
#          }
#        }
#        # Creating a map where the keys are unique usernames.
#        userlist = {
#          for name, info in var.databases :
#          "${name}-${info.owner}" => info.password... # Три крапки групують дублікати
#        }
#        # After grouping, we take only the first password for each user
#        # (since we assume the password is the same for the same owner)
#        userlist = {
#          for owner, passwords in { for name, info in var.databases : "${name}-${info.owner}" => info.password... } :
#          "${owner}" => "${passwords[0]}"
#        }
##        userlist = [
##          for name, info in var.databases : "\"${info.owner}\" \"${info.password}\""
##        ]
#      }
#    })
#  ]
#}