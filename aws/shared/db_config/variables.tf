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

variable "db_instance_identifier" {
  type = string
}