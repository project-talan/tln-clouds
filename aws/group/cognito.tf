// Uncomment the following code if you want to enable Cognito User Pool
// NOTE: user_pool_name & domain should carefully reviewed and updated
/*
  locals {
  email_configuration = {
    email_sending_account  = var.email_configuration.email_sending_account
    reply_to_email_address = (var.email_configuration.reply_to_email_address != "" ? var.email_configuration.reply_to_email_address : "no-reply@no-reply.${var.domain_name}")
    source_arn = module.ses.ses_domain_identity_arn  
    from_email_address     = (var.email_configuration.from_email_address != "" ? var.email_configuration.from_email_address : "no-reply@no-reply.${var.domain_name}")
  }
}
module "cognito" {
  source = "../shared/cognito"

  api_base_url = var.cognito_api_base_url
  user_pool_name = module.shared.prefix_group
  alias_attributes = var.cognito_alias_attributes
  auto_verified_attributes = var.cognito_auto_verified_attributes
  verification_message_template_default_email_option = var.cognito_verification_message_template_default_email_option
  admin_create_user_config_allow_admin_create_user_only = var.cognito_admin_create_user_config_allow_admin_create_user_only
  domain = var.cognito_domain

  email_configuration = local.email_configuration

  string_schemas = var.cognito_string_schemas

  lambda_config = var.cognito_lambda_config

  clients = var.cognito_clients

  tags = module.shared.tags

  enable_pre_auth_lambda = var.cognito_enable_pre_auth_lambda
  pre_auth_lambda_source_path = var.cognito_pre_auth_lambda_source_path
}
*/