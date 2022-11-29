module "shared" {
  source        = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  ii_id       = var.ii_id
  env_id      = var.env_id
  tenant_id   = var.tenant_id
}


data "aws_availability_zones" "available" {
  state = "available"
}
