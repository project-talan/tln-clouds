resource "aws_security_group" "ng1" {
  description = "open ssh to bastion host"
  name_prefix = "ng1"
  vpc_id      = data.aws_vpc.main.id
  
  # Removed inline ingress rules https://registry.terraform.io/providers/hashicorp/aws/5.96.0/docs/resources/security_group
}

resource "aws_vpc_security_group_ingress_rule" "ng1_ssh" {
  security_group_id = aws_security_group.ng1.id
  
  cidr_ipv4   = "10.0.0.0/8"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
  description = "SSH access from private network"
}

resource "local_sensitive_file" "kubeconfig" {
  filename        = module.shared.k8s_config_name
  file_permission = "400"
  content         = local.kubeconfig
}
