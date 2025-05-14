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
variable "rds_pg" {
  type = object({
    size = string
    allocated_storage = string
    max_allocated_storage = string
    master_user_password = bool
    engine_version = string
    family = string
    major_engine_version = string
    multi_az = bool
    manage_master_user_password = bool
    backup_schedule = string
    backup_lifecycle = string
    rds_snapshot_identifier = string
  })
  default = {
    size = "db.t4g.micro"
    allocated_storage = "20"
    max_allocated_storage = "30"
    master_user_password = true
    engine_version = "17.4"
    family = "postgres17"
    major_engine_version = "17"
    multi_az = false
    manage_master_user_password = true
    backup_schedule = "cron(0 */2 * * ? *)"
    backup_lifecycle = "1"
    rds_snapshot_identifier = null
  }
}

variable "databases" {
  description = "A map of databases, their owners and passwords"
  type = map(object({
    owner = string,
    password = string
  }))
}
