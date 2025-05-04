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

output "bastion_remote_address" {
  description = "Formatted string for SSH connection: user@ip"
  value       = "ubuntu@${aws_instance.jumpserver.public_ip}"
}

