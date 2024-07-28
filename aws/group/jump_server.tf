/*
data "aws_ami" "ubuntu" {
  most_recent = false

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-20231030"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

locals {
  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 2)

  instance_type = "t3.micro"
}

module "jump-server-sg-rules" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name   = "${module.shared.prefix_group}-jump-server-sg"
  vpc_id = module.vpc.vpc_id
  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
  egress_rules = ["all-all"]

  tags = module.shared.tags
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.6.0"

  name              = "${module.shared.prefix_group}-vpc"
  cidr              = local.vpc_cidr
  azs               = local.azs
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
  tags               = module.shared.tags
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.group_id}-jump-server-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

module "jump_server" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "5.6.1"

  name                        = "${module.shared.prefix_group}-jump-server"
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = local.instance_type
  key_name                    = aws_key_pair.ssh.key_name
  vpc_security_group_ids      = [module.jump-server-sg-rules.security_group_id]
  subnet_id                   = element(module.vpc.public_subnets, 0)
  associate_public_ip_address = true
  user_data                   = <<EOT
apt install openvpn easy-rsa
  EOT

  root_block_device = [
    {
      encrypted   = true
      volume_type = "gp3"
      volume_size = 20
    }
  ]

  tags = module.shared.tags
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${var.group_id}-bastion-ssh-key.pem"
  file_permission = "400"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_sensitive_file" "bastion_address" {
  filename        = "${var.group_id}-bastion.addr"
  file_permission = "400"
  content         = "ubuntu@${module.jump_server.public_ip}"
}
*/