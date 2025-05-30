variable "org_id" {
  type = string
}
variable "project_id" {
  type = string 
}

variable "repositories" {
  type = list(string)
  default = []
}
variable "image_tag_mutability" {
  type = string
  default = ""
}
