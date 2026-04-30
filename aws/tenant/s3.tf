
locals {
  public_bucket_name  = "${module.shared.prefix_tenant}-public"
  private_bucket_name = "${module.shared.prefix_tenant}-private"
}

module "s3_public" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.12.0" // TODO: Update once all modules used support aws provider v6

  bucket = local.public_bucket_name

  versioning = {
    enabled = true
  }
  attach_policy = true
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowCloudFrontServicePrincipalReadOnly"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "arn:aws:s3:::${local.public_bucket_name}/*"
      }
    ]
  })

  website = {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "aws_s3_bucket_notification" "s3_public_notification" {
  bucket = module.s3_public.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.s3_processor_lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  # relations to processor policy
  depends_on = [aws_iam_policy.s3_processor_policy, module.s3_processor_lambda]
}

resource "aws_s3_bucket_notification" "s3_private_notification" {
  bucket = module.s3_private.s3_bucket_id

  lambda_function {
    lambda_function_arn = module.s3_processor_lambda.lambda_function_arn
    events              = ["s3:ObjectCreated:*"]
  }

  # relations to processor policy
  depends_on = [aws_iam_policy.s3_processor_policy, module.s3_processor_lambda]
}

module "s3_private" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "5.12.0"

  bucket                   = local.private_bucket_name
  acl                      = "private"
  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  versioning = {
    enabled = true
  }

  // TODO: Consider adding logging to here
  force_destroy = true
}

resource "aws_cloudfront_origin_access_control" "public_oac" {
  name                              = "${local.private_bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

module "cloudfront" {
  source  = "terraform-aws-modules/cloudfront/aws"
  version = "6.5.1"

  depends_on = [module.acm]

  aliases = [local.static_domain_name]

  comment             = "CDN for public S3"
  enabled             = true
  default_root_object = "index.html"

  origin = {
    s3_origin = {
      domain_name              = module.s3_public.s3_bucket_bucket_domain_name
      origin_id                = "s3Origin"
      origin_access_control_id = aws_cloudfront_origin_access_control.public_oac.id
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    forwarded_values = {
      query_string = false
      cookies = {
        forward = "none"
      }
    }
  }

  viewer_certificate = {
    acm_certificate_arn      = module.acm.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.3_2025"
  }
}

resource "aws_route53_record" "this" {
  zone_id = local.zone_id
  name    = replace(local.static_domain_name, data.aws_route53_zone.used.name, "")
  type    = "A"

  alias {
    name                   = module.cloudfront.cloudfront_distribution_domain_name
    zone_id                = module.cloudfront.cloudfront_distribution_hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_route53_zone" "used" {
  zone_id = local.zone_id
}
