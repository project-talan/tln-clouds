output "db_instance_address" {
  value       = module.rds_pg.db_instance_address
}

output "db_instance_port" {
  value       = module.rds_pg.db_instance_port
}

output "db_instance_arn" {
  value       = module.rds_pg.db_instance_arn
}

output "db_instance_identifier" {
  value       = module.rds_pg.db_instance_identifier
}

output "db_master_username" {
  value       = module.rds_pg.db_instance_username
}

output "rds_security_group_id" {
  value       = module.rds_pg_security_group.security_group_id
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (if manage_master_user_password is true)."
  value       = module.rds_pg.db_instance_master_user_secret_arn
}
