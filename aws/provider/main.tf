module "shared" {
  source = "../../shared"
  org_id = var.org_id
  project_id = var.project_id
}

resource "aws_ecr_repository" "primary" {
  for_each = var.repositories != "" ? toset(split(",", var.repositories)) : []

  name                 = each.key
  image_tag_mutability = "MUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
  }

  image_scanning_configuration {
    scan_on_push = false
  }
}