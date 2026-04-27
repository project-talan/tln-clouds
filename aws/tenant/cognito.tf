locals {
  api_base_url = "${var.api_base_url}/iam"
  host = var.use_primary_domain ? var.domain_name : "${var.env_id}.${var.domain_name}"
  local_host = "tlnclouds.local"

  callback_urls = [
    "${local.api_base_url}/auth/callback",
    "${local.api_base_url}/swagger/v1/oauth2-redirect.html",
  ]
  callback_urls_dev = [
    "http://localhost:4000/iam/auth/callback",
    "http://localhost:4000/iam/swagger/v1/oauth2-redirect.html",

    "https://api.${local.local_host}/iam/auth/callback",
    "https://api.${local.local_host}/iam/swagger/v1/oauth2-redirect.html"
  ]

  logout_urls = [
    "https://${local.host}",
    "https://admin.${local.host}",
    "https://store.${local.host}",
    "https://${var.tenant_id}.${local.host}"
  ]
  logout_urls_dev = [
    "http://localhost:3000",

    "https://${local.local_host}",
    "https://${var.tenant_id}.${local.local_host}"
  ]
}

resource "aws_cognito_identity_provider" "provider" {
  for_each = var.identity_providers

  user_pool_id  = data.aws_cognito_user_pool.primary.id
  provider_name = each.key
  provider_type = each.value.provider_type

  provider_details = each.value.provider_details

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }

  lifecycle {
    ignore_changes = [
      # do not change provider_details
      provider_details["attributes_url_add_attributes"],
    ]
  }
}


resource "aws_cognito_user_pool_client" "primary" {
  name = var.tenant_id
  user_pool_id = data.aws_cognito_user_pool.primary.id

  access_token_validity = 24
  id_token_validity = 24
  refresh_token_validity  = 30
  token_validity_units {
    access_token = "hours"
    id_token = "hours"
    refresh_token = "days"
  }

  callback_urls = var.group_id == "dev" ? concat(local.callback_urls, local.callback_urls_dev) : local.callback_urls
  logout_urls   = var.group_id == "dev" ? concat(local.logout_urls, local.logout_urls_dev) : local.logout_urls

  default_redirect_uri = "${local.api_base_url}/auth/callback"
  generate_secret = true
  allowed_oauth_scopes = ["email", "openid", "profile"]
  supported_identity_providers = concat(keys(var.identity_providers), var.use_cognito_provider?["COGNITO"]:[])
  allowed_oauth_flows = ["code"]
  explicit_auth_flows = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
  allowed_oauth_flows_user_pool_client = true

  depends_on = [ aws_cognito_identity_provider.provider ]
}

resource "aws_cognito_user_group" "tenant" {
  name         = "tenant:${var.tenant_id}"
  user_pool_id = data.aws_cognito_user_pool.primary.id
  description  = "Tenant (${var.tenant_id}) user group"
}
