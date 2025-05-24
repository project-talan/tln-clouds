output "jumpbox_remote_address" {
  description = "SSH connection string for the bastion host (user@ip)."
  value       = module.jumpbox.jumpserver_remote_address
}