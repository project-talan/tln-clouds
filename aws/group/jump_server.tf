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

module "jump-server-sg-rules" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name = "${module.shared.prefix_group}-jump-server-sg"
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

resource "aws_eip" "eip" {
  instance = module.jump_server.id
  domain   = "vpc"
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
  instance_type               = "t3.nano"
  key_name                    = aws_key_pair.ssh.key_name
  vpc_security_group_ids      = [module.jump-server-sg-rules.security_group_id]
  associate_public_ip_address = true
  user_data                   = file("userdata.sh")

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