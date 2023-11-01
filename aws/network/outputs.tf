output "bastion_remote_address" {
  value = "ubuntu@${aws_instance.bastion.public_ip}"
}
