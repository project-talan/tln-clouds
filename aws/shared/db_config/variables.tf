variable "main-host" {
  type = string
}

variable "emteko-host" {
  type = string
}

variable "databases" {
  type = map(object({
    owner    = string
    password = string
  }))
}

#variable "db_instance_identifier_main" {
#  type = string
#}
#
#variable "db_instance_identifier_emteko" {
#  type = string
#}

variable "rds_security_group_id_main" {
  type = string
}

variable "rds_security_group_id_emteko" {
  type = string
}

variable "tags" {
  type        = map(string)
  default     = {}
}

variable "bastion_security_group_id" {
  type        = string
}

variable "db_instance_master_user_secret_arn_main" {
  type = string
}

variable "db_instance_master_user_secret_arn_emteko" {
  type = string
}