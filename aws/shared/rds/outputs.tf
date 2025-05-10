output "db_instance_address" {
  description = "The address of the RDS instance."
  value       = module.rds_pg.db_instance_address
}

output "db_instance_port" {
  description = "The port of the RDS instance."
  value       = module.rds_pg.db_instance_port
}

output "db_instance_arn" {
  description = "The ARN of the RDS instance."
  value       = module.rds_pg.db_instance_arn
}

output "db_instance_identifier" {
  description = "The identifier of the RDS instance."
  value       = module.rds_pg.db_instance_identifier
}

output "db_master_username" {
  description = "The master username for the RDS instance."
  value       = module.rds_pg.db_instance_username
}

output "rds_security_group_id" {
  description = "The ID of the RDS security group."
  value       = aws_security_group.postgres_sg.id
}

output "db_instance_master_user_secret_arn" {
  description = "The ARN of the master user secret (if manage_master_user_password is true)."
  value       = module.rds_pg.db_instance_master_user_secret_arn
}
