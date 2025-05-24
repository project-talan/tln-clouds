variable "org_id" {
  type = string
}
variable "project_id" {
  type = string 
}
variable "group_id" {
  type = string 
}

variable "domain_name" {
  type = string
  default = ""
}
variable "env_id" {
  type = string
  default = ""
}

variable "jumpbox_instance_type" {
  description = "Instance type for the bastion host."
  type        = string
  default     = "t3.micro"
}
variable "jumpbox_custom_packages" {
  type        = map(string)
  default     = {
    openvpn: "2.6.12"
    easy-rsa: "3.1.7"
  }
}

 