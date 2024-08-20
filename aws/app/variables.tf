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

variable "rds_pg_db_size" {
  type = string
}
variable "rds_pg_db_allocated_storage" {
  type = string
}
variable "rds_pg_max_allocated_storage" {
  type = string
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
