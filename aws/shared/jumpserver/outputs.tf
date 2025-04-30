output "instance_id" {
  description = "The ID of the jump server EC2 instance."
  value       = aws_instance.jumpserver.id
}

output "public_ip" {
  description = "The public IP address of the jump server."
  value       = aws_instance.jumpserver.public_ip
}


output "key_name" {
  description = "The name of the AWS key pair created for the jump server."
  value       = aws_key_pair.ssh.key_name
}

output "security_group_id" {
  description = "The ID of the security group attached to the jump server."
  value       = aws_security_group.jumpserver_sg.id
}

output "ssh_user" {
  description = "Default SSH user for the Ubuntu AMI."
  value       = "ubuntu" # Common default for Ubuntu AMIs
}

output "bastion_remote_address" {
  description = "Formatted string for SSH connection: user@ip"
  value       = "ubuntu@${aws_instance.jumpserver.public_ip}"
}
output "ssh_private_key" {
  description = "The private key for SSH access to the jump server."
  value       = tls_private_key.ssh.private_key_pem
  sensitive  = true
}
