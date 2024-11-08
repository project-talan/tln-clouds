// Uncomment the following code if you want to enable Cognito User Pool
// NOTE: user_pool_name & domain should carefully reviewed and updated

/*
locals {
  api_base_url = "http://localhost"
}

module "cognito_user_pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.30.0"

  user_pool_name                                        = module.shared.prefix_group
  alias_attributes                                      = ["email", "preferred_username"]
  auto_verified_attributes                              = ["email"]
  verification_message_template_default_email_option    = "CONFIRM_WITH_LINK"
  admin_create_user_config_allow_admin_create_user_only = false
  domain                                                = module.shared.prefix_group

//  mfa_configuration           = "ON"
//  software_token_mfa_configuration = {
//    enabled = true
//  }

  email_configuration = {
    email_sending_account  = "DEVELOPER"
    reply_to_email_address = "no-reply@no-reply.${var.domain_name}"
    source_arn             = module.ses.ses_domain_identity_arn
    from_email_address     = "no-reply@no-reply.${var.domain_name}"
  }

  string_schemas = [
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

//  lambda_config = {
//    pre_authentication = module.cognito_pre_auth_function.lambda_function_arn
//  }

  clients = [
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
      callback_urls = [
        "${local.api_base_url}/iam/login/oauth2/code/cognito",
        "${local.api_base_url}/iam/swagger-ui/oauth2-redirect.html"
      ]
      logout_urls                  = [
        "${local.api_base_url}/iam/auth/complete",
      ]
      default_redirect_uri         = "${local.api_base_url}/iam/login/oauth2/code/cognito"
      generate_secret              = true
      allowed_oauth_scopes         = ["openid", "email"]
      supported_identity_providers = ["COGNITO"]
      allowed_oauth_flows          = ["code"]
      explicit_auth_flows          = ["ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH"]
      allowed_oauth_flows_user_pool_client = true
    }
  ]

//  depends_on = [ module.cognito_pre_auth_function ]

  tags = module.shared.tags
}
*/

/*
module "cognito_pre_auth_function" {
  source = "terraform-aws-modules/lambda/aws"
  version = "7.13.0"

  function_name = "${module.shared.prefix_group}-cognito-pre-auth"
  description   = "Cognito Pre-auth function"
  handler       = "cognito-pre-auth.lambda_handler"
  runtime       = "python3.12"

  lambda_role   = aws_iam_role.cognito_pre_auth_aim.arn
  source_path = "src/cognito-pre-auth.py"

  depends_on = [ aws_iam_role_policy_attachment.cognito_pre_auth_policy_attachment ]

  tags = module.shared.tags
}

resource "aws_iam_role" "cognito_pre_auth_aim" {
  name = "${module.shared.prefix_group}-cognito-pre-auth-aim"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      },
    ]
  })
}

resource "aws_iam_policy" "cognito_pre_auth_aim_policy" {
  name = "${module.shared.prefix_group}-cognito-pre-auth-aim-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "cognito-idp:AdminUpdateUserAttributes"
        Effect = "Allow"
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_pre_auth_policy_attachment" {
  role       = aws_iam_role.cognito_pre_auth_aim.name
  policy_arn = aws_iam_policy.cognito_pre_auth_aim_policy.arn

  depends_on = [ aws_iam_role.cognito_pre_auth_aim, aws_iam_policy.cognito_pre_auth_aim_policy ]
}

resource "aws_lambda_permission" "cognito_pre_auth_function_invoke_permission" {
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_pre_auth_function.lambda_function_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.arn
}
*/