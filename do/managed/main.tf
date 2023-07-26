module "shared" {
  source      = "../../shared"
  org_id      = var.org_id
  project_id  = var.project_id
  env_id      = var.env_id
/*
  tenant_id   = var.tenant_id
*/
}

resource "digitalocean_kubernetes_cluster" "k8s" {
  name      = module.shared.k8s_name
  region    = var.do_region
  vpc_uuid  = data.digitalocean_vpc.vpc.id
  version   = var.do_k8s_version

  node_pool {
    name        = module.shared.k8s_pool_name
    auto_scale  = true
    min_nodes   = var.do_k8s_nodes_min
    max_nodes   = var.do_k8s_nodes_max
    size        = var.do_k8s_nodes_size

    tags        = data.digitalocean_tags.list.tags[*].name
  }

  tags          = data.digitalocean_tags.list.tags[*].name
}
