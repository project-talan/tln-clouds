output "cluster_name" {
  value = module.eks.cluster_name
}
output "cluster_arn" {
  value = module.eks.cluster_arn
}
output "cluster_version" {
  value = module.eks.cluster_version
}
output "access_entries" {
  value = module.eks.access_entries
}
output "access_policy_associations" {
  value = module.eks.access_policy_associations
}
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}
output "cluster_addons" {
  value = module.eks.cluster_addons
}
output "cluster_identity_providers" {
  value = module.eks.cluster_identity_providers
}
output "oidc_provider" {
  value = module.eks.oidc_provider
}
output "oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
output "cluster_dualstack_oidc_issuer_url" {
  value = module.eks.cluster_dualstack_oidc_issuer_url
}
output "self_managed_node_groups" {
  value = module.eks.self_managed_node_groups
}
output "eks_managed_node_groups_autoscaling_group_names" {
  value = module.eks.self_managed_node_groups_autoscaling_group_names
}
