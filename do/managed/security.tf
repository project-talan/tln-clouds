
resource "local_sensitive_file" "kubeconfig" {
  filename          = module.shared.k8s_config_name
  file_permission   = "400"
  content           = digitalocean_kubernetes_cluster.k8s.kube_config[0].raw_config
}
