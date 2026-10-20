mock_provider "aws" {
  mock_data "aws_eks_cluster" {
    defaults = {
      certificate_authority = [{ data = "" }]
      identity              = [{ oidc = [{ issuer = "https://oidc.example" }] }]
    }
  }
}
mock_provider "awscc" {}
mock_provider "helm" {}
mock_provider "kubernetes" {}
mock_provider "postgresql" {}

override_module {
  target = module.cognito_user_pool
}
override_module {
  target = module.lb_controller_irsa_role
}
override_module {
  target = module.rds
}

variables {
  org_id             = "o"
  project_id         = "p"
  group_id           = "g"
  env_id             = "e"
  domain_name        = "example.com"
  dns_records        = ""
  use_primary_domain = false
  api_base_url       = "https://api.example.com"
  databases          = {}
}

run "nginx_upgrade_rolls_pods_instead_of_recreating" {
  command = plan

  providers = {
    aws        = aws
    awscc      = awscc
    helm       = helm
    kubernetes = kubernetes
    postgresql = postgresql
  }

  assert {
    condition     = !helm_release.nginx.recreate_pods
    error_message = "recreate_pods deletes every ingress-nginx pod at once on upgrade; let the Deployment roll them"
  }
}
