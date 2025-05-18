variable "org_id" {
  type = string
}
variable "project_id" {
  type = string 
}
variable "group_id" {
  type = string 
}

variable "domain_name" {
  type = string
  default = ""
}

variable "jumpbox_instance_type" {
  description = "Instance type for the bastion host."
  type        = string
  default     = "t3.micro"
}
variable "jumpbox_custom_packages" {
  type        = map(string)
  default     = {
    openvpn: "2.6.13"
    easy-rsa: "3.2.2"
  }
}

variable "cognito_api_base_url" {
  type    = string
  default = "http://localhost"
}

variable "cognito_alias_attributes" {
  type    = list(string)
  default = ["email", "preferred_username"]
}

variable "cognito_auto_verified_attributes" {
  type    = list(string)
  default = ["email"]
}

variable "cognito_verification_message_template_default_email_option" {
  type    = string
  default = "CONFIRM_WITH_LINK"
}

variable "cognito_admin_create_user_config_allow_admin_create_user_only" {
  type    = bool
  default = false
}

variable "cognito_domain" {
  type    = string
  default = null
}

variable "email_configuration" {
  type = object({
    email_sending_account  = string
    reply_to_email_address = string
    source_arn             = string
    from_email_address     = string
  })
  default = {
    email_sending_account  = "DEVELOPER"
    reply_to_email_address = ""
    source_arn             = ""
    from_email_address     = ""
  }
}
variable "cognito_string_schemas" {
  type = list(any)
  default = [
    {
      attribute_data_type      = "String"
      name                     = "email"
      mutable                  = true
      required                 = true
      developer_only_attribute = false
      string_attribute_constraints = {
        min_length = 0
        max_length = 2048
      }
    },
  ]
}

variable "cognito_lambda_config" {
  type    = any
  default = {}
}

variable "cognito_clients" {
  type = list(any)
  default = [
    {
      name = "Web"
      access_token_validity = 24
      id_token_validity = 24
      refresh_token_validity  = 30
      token_validity_units = {
        access_token  = "hours"
        id_token      = "hours"
        refresh_token = "days"
      }
      generate_secret              = true
      allowed_oauth_scopes         = ["openid", "email"]
      supported_identity_providers = ["COGNITO"]
      allowed_oauth_flows          = ["code"]
      explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
      allowed_oauth_flows_user_pool_client = true
    }
  ]
}

variable "cognito_enable_pre_auth_lambda" {
  type    = bool
  default = false
}

variable "cognito_pre_auth_lambda_source_path" {
  type    = string
  default = ""
}

