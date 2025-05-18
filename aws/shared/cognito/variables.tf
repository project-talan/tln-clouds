variable "api_base_url" {
  type = string
}

variable "user_pool_name" {
  type = string
}

variable "alias_attributes" {
  type    = list(string)
  default = ["email", "preferred_username"]
}

variable "auto_verified_attributes" {
  type    = list(string)
  default = ["email"]
}

variable "verification_message_template_default_email_option" {
  type    = string
  default = "CONFIRM_WITH_LINK"
}

variable "admin_create_user_config_allow_admin_create_user_only" {
  type    = bool
  default = false
}

variable "domain" {
  type = string
}

variable "email_configuration" {
  type = object({
    email_sending_account  = string
    reply_to_email_address = string
    source_arn             = string
    from_email_address     = string
  })
}

variable "string_schemas" {
  type = list(any)
}

variable "lambda_config" {
  type    = any
  default = {}
}

variable "clients" {
  type = list(any)
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "enable_pre_auth_lambda" {
  type    = bool
  default = false
}

variable "pre_auth_lambda_source_path" {
  type    = string
  default = ""
}
