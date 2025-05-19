locals {
  create_security_group = var.use_default_vpc ? false : true
  create_outbound_rule  = var.use_default_vpc ? false : true
  security_group_id     = var.use_default_vpc ? data.aws_security_group.jumpbox.id : aws_security_group.jumpserver_sg[0].id
}
data "aws_ami" "ubuntu" {
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


locals {
  ami_id = data.aws_ami.ubuntu.id

  flattened_custom_packages_map = flatten([
    for key, value in var.custom_packages :
    [key, value]
  ])

  tags = merge(
    {
      "Name" = "${var.resources_prefix}"
    },
    var.tags
  )
}

resource "aws_security_group" "jumpserver_sg" {
  count       = local.create_security_group ? 1 : 0 #checking if we need to create a new security group or use the default one
  name        = "${var.resources_prefix}-sg"
  description = "Allow SSH access to the jump server"
  vpc_id      = data.aws_vpc.jumpbox.id

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  for_each = toset(var.allowed_ssh_cidr_blocks)

  security_group_id = local.security_group_id
  cidr_ipv4         = each.key
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
  description       = "Allow SSH from ${each.key}"
  tags = merge(local.tags, {
    RuleDescription = "Allow SSH from ${each.key}"
  })
}

resource "aws_vpc_security_group_egress_rule" "allow_all_outbound" {
  count             = local.create_outbound_rule ? 1 : 0 #default security group already allows all outbound
  security_group_id = local.security_group_id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # All protocols
  description       = "Allow all outbound traffic"
  tags = merge(local.tags, {
    RuleDescription = "Allow all outbound"
  })
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ssh" {
  key_name   = "${var.resources_prefix}-ssh-key"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = local.tags
}

resource "aws_instance" "jumpserver" {
  ami                         = local.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true # Jump server needs public IP

  vpc_security_group_ids = [local.security_group_id]
  key_name               = aws_key_pair.ssh.key_name
  user_data = base64encode(templatefile("${path.module}/templates/template.sh.tftpl", {
    custom_packages = join(",", local.flattened_custom_packages_map)
  }))


  user_data_replace_on_change = true

  metadata_options {
    http_tokens                 = "required"
    http_endpoint               = "enabled"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "disabled"
  }
  root_block_device {
    encrypted   = true
    volume_type = "gp3"
    volume_size = var.jumpserver_volume_size
  }

  tags = local.tags
}

# Add local file resources to save key and address
resource "local_sensitive_file" "ssh_private_key_pem" {
  filename        = "${var.files_prefix}-ssh-key.pem"
  file_permission = "400"
  content         = tls_private_key.ssh.private_key_pem
}

resource "local_sensitive_file" "bastion_address" {
  filename        = "${var.files_prefix}.addr"
  file_permission = "400"
  content         = "ubuntu@${aws_instance.jumpserver.public_ip}"
}
