/*
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "5.2.0"

  domain_name = var.domain_name
  zone_id     = var.zone_id

  subject_alternative_names = [
    "*.${var.domain_name}"
  ]

  create_route53_records = true
  wait_for_validation    = true
  validation_method      = "DNS"

  tags = {
    Name = var.domain_name
  }
}
*/