variable "org_id" {
  type = string
}
variable "project_id" {
  type = string 
}
variable "group_id" {
  type = string 
}
variable "env_id" {
  type = string 
}
variable "tenant_id" {
  type = string 
}

variable "domain_name" {
  type = string
}
variable "use_primary_domain" {
  type = bool
}
variable "api_base_url" {
  type = string
}
variable "user_pool_id" {
  type = string
}
variable "identity_providers" {
  description = "Tenant identity providers"
  type = map(object({
    provider_type = string,
    provider_details = object({
      attributes_request_method = string,
      attributes_url = string,
      authorize_scopes = string,
      authorize_url = string,
      client_id = string,
      client_secret = string,
      jwks_uri = string,
      oidc_issuer = string,
      token_url = string
    })
  }))
}
variable "use_cognito_provider" {
  type = bool
}
variable "db_instance_identifier" {
  type = string
}
variable "tenant_databases" {
  description = "A map of databases, their owners and passwords"
  type = map(object({
    owner = string,
    password = string
  }))
}
