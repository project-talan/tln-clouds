#AUTH QURY does not work because of permission
#locals {
#  auth_query_script = <<EOT
#      set -e # Зупинити скрипт, якщо будь-яка команда впаде
#      export PGPASSWORD='${jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]}'
#
#      # Додаємо -v ON_ERROR_STOP=1, щоб psql повертав помилку в Terraform
#      psql -h ${module.rds_pg.db_instance_address} -U ${module.rds_pg.db_instance_username} -d postgres -v ON_ERROR_STOP=1 <<EOF
#
#      GRANT pg_read_all_settings TO "${module.rds_pg.db_instance_username}";
#
#
#      CREATE SCHEMA IF NOT EXISTS pgbouncer;
#
#      CREATE OR REPLACE FUNCTION pgbouncer.get_auth(p_usename text)
#      RETURNS TABLE(usename text, passwd text) AS \$\$
#      BEGIN
#          RETURN QUERY
#          SELECT s.usename::text, s.passwd::text
#          FROM pg_catalog.pg_shadow s
#          WHERE s.usename = p_usename;
#      END;
#      \$\$ LANGUAGE plpgsql SECURITY DEFINER;
#      SET search_path = pg_catalog, pgbouncer;
#
#      ALTER FUNCTION pgbouncer.get_auth(text) OWNER TO "${module.rds_pg.db_instance_username}";
#
#      GRANT USAGE ON SCHEMA pgbouncer TO pgbouncer_auth;
#      GRANT EXECUTE ON FUNCTION pgbouncer.get_auth(text) TO pgbouncer_auth;
#EOF
#    EOT
#}
#
#resource "postgresql_role" "pgbouncer_auth" {
#  depends_on = [module.rds_pg, resource.aws_vpc_security_group_ingress_rule.allow_bastion]
#  provider = postgresql.rds_admin
#  name     = "pgbouncer_auth"
#  login    = true
#  password = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]# Краще використовувати var або random_password
#}
#
#resource "postgresql_schema" "pgbouncer_schema" {
#  provider = postgresql.rds_admin
#  name  = "pgbouncer"
#  //owner = "postgres"
#}
#
#resource "postgresql_extension" "plpgsql" {
#  provider = postgresql.rds_admin
#  name = "plpgsql"
#}
#
#resource "null_resource" "setup_auth_function_1" {
#  depends_on = [postgresql_role.pgbouncer_auth, postgresql_schema.pgbouncer_schema]
#
#  # 1. Додаємо тригер тут
#  triggers = {
#    # Хеш від тексту команди. Якщо команда зміниться — тригер спрацює
#    command_hash = sha256(local.auth_query_script)
#  }
#
#  provisioner "local-exec" {
#    command = local.auth_query_script
#  }
#}



resource "helm_release" "pgbouncer" {
  depends_on       = [module.rds_pg]

  name             = "pgbouncer"
  repository       = "https://icoretech.github.io/helm"
  chart            = "pgbouncer"
  namespace        = "database-${keys(var.databases)[0]}"
  create_namespace = true
  cleanup_on_fail  = true

  # Forces Kubernetes to recreate pods if the configuration changes.
  force_update     = true
  recreate_pods    = true
  replace          = true

  version          = "2.1.1"


#  set = {
#    name  = "config.userlist"
#    # We use join to convert a list into a SINGLE string with newlines. \n
#    value = join("\n", [
#      for name, info in var.databases : "\"${info.owner}\" \"${info.password}\""
#    ])
#  }
#  set = [
#    for name, data in var.databases : {
#      name  = "config.databases.${name}"
#      value = "host=${module.rds_pg.db_instance_address} port=5432 dbname=${name} user=${data.owner} password=${data.password}"
#      }
#  ]

#  value = "postgres://${data.owner}:${data.password}@${module.rds_pg.db_instance_address}:5432/${name}"
  set = [ {
    # Додаємо .pgbouncer_auth до шляху, щоб створити ключ у map
    name  = "config.userlist.pgbouncer_auth"
    value = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]
  }]
  # Example of passing custom configuration
  values = [
    file("${path.module}/chart/pgbouncer/pgbouncer-values.yaml"),

    yamlencode({
      config = {
        //auth_type = "md5"
        auth_type: "scram-sha-256"
        server_tls_sslmode = "require"
        # Retrieving the password from AWS Secrets Manager or a variable.
        adminPassword = jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]
        databases = merge(
          {
          for name, data in var.databases : name => {
            host=module.rds_pg.db_instance_address
            port=5432
            user="${name}-${data.owner}"
            password=data.password
            dbname=name }
        },
          {
            # wildcard allow to connect to any db on this host
            "*" = {
              host   = module.rds_pg.db_instance_address
              port   = 5432
            }
          }
        )
        # do not use parametr, which JDBC driver send automatically.
        ignoreStartupParameters = "extra_float_digits,search_path"

        # for support preparead in version(1.21+)
        # if you use old version, please use 0 and set up  JDBC URL
        maxPreparedStatements = 10
        #!!!!!!PLEASE USE THIS PARAMETR IN
        #JDBC URL_______?prepareThreshold=0&preparedStatementCacheQueries=0

#        auth_dbname: "postgres" # <--- Обов'язково, якщо функція в базі postgres
#        auth_user: "pgbouncer_auth"
#        auth_query: "SELECT * FROM pgbouncer.get_auth($1)"
        //userlist = { "\"pgbouncer_auth\" \"${jsondecode(data.aws_secretsmanager_secret_version.rds_pg_master_password.secret_string)["password"]}\"" }

        # Creating a map where the keys are unique usernames.
        userlist = {
          for name, info in var.databases :
          "${name}-${info.owner}" => info.password... # Три крапки групують дублікати
        }
        # After grouping, we take only the first password for each user
        # (since we assume the password is the same for the same owner)
        userlist = {
          for owner, passwords in { for name, info in var.databases : "${name}-${info.owner}" => info.password... } :
          "${owner}" => "${passwords[0]}"
        }
        userlist = [
          for name, info in var.databases : "\"${info.owner}\" \"${info.password}\""
        ]
      }
    })
  ]
}