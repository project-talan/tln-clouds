
locals {
  api_base_url = "${var.api_base_url}/iam"
}

module "cognito_user_pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.35.0"

  user_pool_name                                        = module.shared.prefix_env
  alias_attributes                                      = ["email", "preferred_username"]
  auto_verified_attributes                              = ["email"]

  deletion_protection = "ACTIVE"

  mfa_configuration = "OPTIONAL"
  software_token_mfa_configuration = {
    enabled = true
  }

  admin_create_user_config = {
    allow_admin_create_user_only = false
  }

  email_configuration = {
    email_sending_account  = "DEVELOPER"
    reply_to_email_address = "no-reply@no-reply.${var.domain_name}"
    source_arn             = data.aws_ses_domain_identity.primary.arn
    from_email_address     = "no-reply@no-reply.${var.domain_name}"
  }
  /*
  lambda_config = {
    create_auth_challenge           = 
    custom_message                  = 
    define_auth_challenge           = 
    post_authentication             = 
    post_confirmation               = 
    pre_authentication              = module.cognito_pre_auth_function.lambda_function_arn
    pre_sign_up                     = 
    pre_token_generation            = 
    user_migration                  = 
    verify_auth_challenge_response  = 
  }
  */

  password_policy = {
    minimum_length                   = 10
    require_lowercase                = false
    require_numbers                  = true
    require_symbols                  = true
    require_uppercase                = true
    temporary_password_validity_days = 120
    password_history_size            = 5    
  }

  user_pool_add_ons = {
    advanced_security_mode = "ENFORCED"
  }

  verification_message_template = {
    default_email_option = "CONFIRM_WITH_CODE"
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

  domain = module.shared.prefix_env

//  depends_on = [ module.cognito_pre_auth_function ]
  tags = module.shared.tags
}

/*
module "cognito_pre_auth_function" {
  source = "terraform-aws-modules/lambda/aws"

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