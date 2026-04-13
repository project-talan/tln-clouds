variable "databases" {
  description = "A map of databases, their owners and passwords"
  type = map(object({
    owner = string,
    password = string
  }))
}

variable "db_instance_identifier" {
  type = string
}
