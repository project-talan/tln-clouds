module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}
