variable "org_id" {
  type = string
}
variable "project_id" {
  type = string 
}
variable "group_id" {
  type = string 
}
variable "env_id" {
  type = string 
}

variable "domain_name" {
  type = string
}
variable "dns_records" {
  type = string
}
variable "use_primary_domain" {
  type = bool
}

variable "rds_pg_db_size" {
  type = string
  default = "db.t4g.micro"
}
variable "rds_pg_db_allocated_storage" {
  type = string
  default = "20"
}
variable "rds_pg_max_allocated_storage" {
  type = string
  default = "30"
}
variable rds_manage_master_user_password {
  type    = bool
  default = true
}
variable "rds_engine_version" {
  type    = string
  default = "17.4"
}
variable "rds_family" {
  type    = string
  default = "postgres17"
}
variable "rds_major_engine_version" {
  type    = string
  default = "17"
}
variable "rds_multi_az" {
  type    = bool
  default = false
}
variable "databases" {
  description = "A map of databases, their owners and passwords"
  type = map(object({
    owner = string,
    password = string
  }))
}
variable "backup_schedule" {
  type = string
  default = "cron(0 */2 * * ? *)"
}
variable "backup_lifecycle" {
  type = string
  default = "1"
}
variable "snapshot_identifier" {
  type    = string
  default = null
}

