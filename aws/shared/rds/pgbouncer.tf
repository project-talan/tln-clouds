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
        # do not use parameter, which JDBC driver send automatically.
        ignoreStartupParameters = "extra_float_digits,search_path"

        # for support prepared in version(1.21+)
        # if you use old version, please use 0 and set up  JDBC URL
        maxPreparedStatements = 10
        #!!!!!!PLEASE USE THIS PARAMETER IN connection string of your java application
        #JDBC URL_______?prepareThreshold=0&preparedStatementCacheQueries=0

        # Creating a map where the keys are unique usernames.
        userlist = {
          for name, info in var.databases :
          "${name}-${info.owner}" => info.password... # three dots groups the duplicate
        }
        # After grouping, we take only the first password for each user
        # (since we assume the password is the same for the same owner)
        userlist = {
          for owner, passwords in { for name, info in var.databases : "${name}-${info.owner}" => info.password... } :
          "${owner}" => "${passwords[0]}"
        }
      }
    })
  ]
}