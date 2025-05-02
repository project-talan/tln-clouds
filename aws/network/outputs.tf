output "bastion_remote_address" {
  description = "SSH connection string for the bastion host (user@ip)."
  value       = module.bastion.bastion_remote_address
}
