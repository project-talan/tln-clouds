module "shared" {
  source      = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  env_id      = var.env_id
/*
  tenant_id   = var.tenant_id
*/
}

/*
resource "digitalocean_certificate" "certificate" {
  name              = "${module.shared.prefix_env}-${var.domain_tag}-cert"
  type              = "custom"
  private_key       = file(var.private_key)
  certificate_chain = file(var.certificate_chain)
  leaf_certificate = file(var.leaf_certificate)
}
*/