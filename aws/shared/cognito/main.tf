locals {
  api_base_url = var.api_base_url
}

module "cognito_user_pool" {
  source  = "lgallard/cognito-user-pool/aws"
  version = "0.30.0"

  user_pool_name                                        = var.user_pool_name
  alias_attributes                                      = var.alias_attributes
  auto_verified_attributes                              = var.auto_verified_attributes
  verification_message_template_default_email_option    = var.verification_message_template_default_email_option
  admin_create_user_config_allow_admin_create_user_only = var.admin_create_user_config_allow_admin_create_user_only
  domain                                                = var.domain

  email_configuration = var.email_configuration

  string_schemas = var.string_schemas

  lambda_config = var.lambda_config

  clients = [
    for client in var.clients : merge(client, {
      callback_urls = [
        "${local.api_base_url}/iam/login/oauth2/code/cognito",
        "${local.api_base_url}/iam/swagger-ui/oauth2-redirect.html"
      ],
      logout_urls = [
        "${local.api_base_url}/iam/auth/complete"
      ],
      default_redirect_uri = "${local.api_base_url}/iam/login/oauth2/code/cognito"
    })
  ]

  tags = var.tags
}

resource "aws_iam_role" "cognito_pre_auth_aim" {
  count = var.enable_pre_auth_lambda ? 1 : 0
  name = "${var.user_pool_name}-cognito-pre-auth-aim"
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
  count = var.enable_pre_auth_lambda ? 1 : 0
  name = "${var.user_pool_name}-cognito-pre-auth-aim-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "cognito-idp:AdminUpdateUserAttributes"
        Effect = "Allow"
        Resource = module.cognito_user_pool.arn
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "cognito_pre_auth_policy_attachment" {
  count      = var.enable_pre_auth_lambda ? 1 : 0
  role       = aws_iam_role.cognito_pre_auth_aim[0].name
  policy_arn = aws_iam_policy.cognito_pre_auth_aim_policy[0].arn

  depends_on = [
    aws_iam_role.cognito_pre_auth_aim,
    aws_iam_policy.cognito_pre_auth_aim_policy
  ]
}

module "cognito_pre_auth_function" {
  source  = "terraform-aws-modules/lambda/aws"
  version = "7.13.0"

  count         = var.enable_pre_auth_lambda ? 1 : 0
  function_name = "${var.user_pool_name}-cognito-pre-auth"
  description   = "Cognito Pre-auth function"
  handler       = "cognito-pre-auth.lambda_handler"
  runtime       = "python3.12"

  lambda_role   = aws_iam_role.cognito_pre_auth_aim[0].arn
  source_path   = var.pre_auth_lambda_source_path

  depends_on = [aws_iam_role_policy_attachment.cognito_pre_auth_policy_attachment]

  tags = var.tags
}

resource "aws_lambda_permission" "cognito_pre_auth_function_invoke_permission" {
  count        = var.enable_pre_auth_lambda ? 1 : 0
  statement_id  = "AllowExecutionFromCognito"
  action        = "lambda:InvokeFunction"
  function_name = module.cognito_pre_auth_function[0].lambda_function_arn
  principal     = "cognito-idp.amazonaws.com"
  source_arn    = module.cognito_user_pool.arn
}
