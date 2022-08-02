module "shared" {
  source        = "../../shared"
  project_name  = var.project_name
  ii_name       = var.ii_name
  env_name      = var.env_name
  tenant_name   = var.tenant_name
}
