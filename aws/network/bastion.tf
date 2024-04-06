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

resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true

  vpc_security_group_ids      = [module.bastion_sg.security_group_id]
  key_name                    = aws_key_pair.ssh.key_name

  user_data                   = base64encode(file("${path.module}/templates/template.sh"))
  user_data_replace_on_change = true

  tags = {
    Name = "${var.env_id}-bastion"
  }
}

module "bastion_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.2"

  name        = "${var.env_id}-bastion-sg"
  description = "Security group for web-server to allow SSH access"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
  ]

  egress_rules = ["all-all"]
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.env_id}-bastion-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${var.env_id}-bastion-ssh-key.pem"
  file_permission = "400"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_sensitive_file" "bastion_address" {
  filename        = "${var.env_id}-bastion.addr"
  file_permission = "400"
  content         = "ubuntu@${aws_instance.bastion.public_ip}"
}
