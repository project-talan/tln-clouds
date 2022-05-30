module "shared" {
  source        = "../../shared"
  project_name  = var.project_name
  ii_name       = var.ii_name
  env_name      = var.env_name
  tenant_name   = var.tenant_name
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name      = module.shared.k8s_name
  region    = var.do_region
  vpc_uuid  = data.digitalocean_vpc.vpc.id
  version   = var.do_k8s_version

  node_pool {
    name       = module.shared.k8s_pool_name
    auto_scale = true
    min_nodes  = var.do_k8s_nodes_min
    max_nodes  = var.do_k8s_nodes_max
    size       = var.do_k8s_nodes_size
  }
}
