resource "aws_security_group" "ng1" {
  name_prefix = "ng1"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "tcp"

    cidr_blocks = [
      "10.0.0.0/8",
    ]
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename          = module.shared.k8s_config_name
  file_permission   = "400"
  content           = local.kubeconfig
}
