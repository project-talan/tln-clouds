output "bastion_remote_address" {
    value = "ubuntu@${aws_eip.bastion.public_ip}"
}