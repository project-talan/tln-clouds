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