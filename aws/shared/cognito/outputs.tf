output "user_pool_name" {
  value       = module.cognito_user_pool.name
}
output "user_pool_id" {
  value       = module.cognito_user_pool.id
}
output "user_pool_endpoint" {
  value       = module.cognito_user_pool.endpoint
}

output "user_pool_arn" {
  value       = module.cognito_user_pool.arn
}

output "domain_app_version" {
  value       = module.cognito_user_pool.domain_app_version
}
output "domain_aws_account_id" {
  value       = module.cognito_user_pool.domain_aws_account_id
}

output "client_ids" {
  value       = module.cognito_user_pool.client_ids
}
output "client_ids_map" {
  value       = module.cognito_user_pool.client_ids_map
}

output "client_secrets" {
  value       = module.cognito_user_pool.client_secrets
  sensitive = true
}
output "client_secrets_map" {
  value       = module.cognito_user_pool.client_secrets_map
  sensitive = true
}
output "domain_cloudfront_distribution" {
  value       = module.cognito_user_pool.domain_cloudfront_distribution
}
output "domain_cloudfront_distribution_arn" {
  value       = module.cognito_user_pool.domain_cloudfront_distribution_arn
}
output "domain_cloudfront_distribution_zone_id" {
  value       = module.cognito_user_pool.domain_cloudfront_distribution_zone_id
}

output "pre_auth_lambda_arn" {
  value       = var.enable_pre_auth_lambda ? module.cognito_pre_auth_function[0].lambda_function_arn : null
}
