provider "aws" {
  default_tags {
    tags = merge(module.shared.tags, { group = var.group_id, env = var.env_id, tenant = var.tenant_id } )
  }
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)

  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args = ["eks", "get-token", "--cluster-name", module.shared.k8s_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.shared.k8s_name]
      command     = "aws"
    }
  }
}

provider "postgresql" {
  host      = data.aws_db_instance.this.address
  port      = 5432
  scheme    = "awspostgres"
  username  = "root"
  password  = jsondecode(data.aws_secretsmanager_secret_version.rds_pg.secret_string)["password"]
  sslmode   = "disable"
  superuser = false
}
