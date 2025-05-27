variable "prefix_env" {
  type        = string
}

variable "vpc_id" {
  type        = string
}

variable "db_subnet_group_name" {
  type        = string
}

variable "node_security_group_id" {
  type        = string
}

variable "bastion_security_group_id" {
  type        = string
}

variable "rds_pg_db_size" {
  type        = string
}

variable "rds_pg_db_allocated_storage" {
  type        = number
}

variable "rds_pg_max_allocated_storage" {
  type        = number
}

variable "databases" {
  type = map(object({
    owner    = string
    password = string
  }))
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "backup_schedule" {
  type        = string
}

variable "backup_lifecycle_delete_after" {
  type        = number
  default     = 97 # lifecycle_delete_after cannot be less than 90 days apart from lifecycle_coldstorage_after
}
variable "backup_lifecycle_coldstorage_after" {
  type        = number
  default     = 7
}
variable "rds_engine_version" {

  type        = string
  default     = "17.4"
}

variable "rds_family" {
  type        = string
  default     = "postgres17"
}

variable "rds_major_engine_version" {
  type        = string
  default     = "17"
}

variable "rds_multi_az" {
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  type        = number
  default     = 3
}

variable "rds_skip_final_snapshot" {
  type        = bool
  default     = true
}

variable "rds_deletion_protection" {
  type        = bool
  default     = false
}

variable "rds_performance_insights_enabled" {
  type        = bool
  default     = true
}

variable "rds_performance_insights_retention_period" {
  type        = number
  default     = 7
}

variable "rds_monitoring_interval" {
  type        = number
  default     = 60
}

variable "rds_ca_cert_identifier" {
  type        = string
  default     = "rds-ca-rsa2048-g1"
}
variable "rds_manage_master_user_password" {
  type        = bool
  default     = false
}
variable "rds_snapshot_identifier" {
  type        = string
  default     = ""
}