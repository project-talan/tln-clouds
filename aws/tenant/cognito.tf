locals {
  api_base_url = "${var.api_base_url}/iam"
  logout_url = "https://${var.tenant_id}.${var.domain_name}"
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

  callback_urls = [
    "${local.api_base_url}/auth/callback",
    "${local.api_base_url}/swagger/v1/oauth2-redirect.html",
    "http://localhost:8001/iam/auth/callback"
  ]
  logout_urls = [
    "${local.logout_url}",
    "http://localhost:3000"
  ]
  default_redirect_uri = "${local.api_base_url}/auth/callback"
  generate_secret = true
  allowed_oauth_scopes = ["email", "openid"]
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