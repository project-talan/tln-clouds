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

variable "bastion_instance_type" {
  description = "Instance type for the bastion host."
  type        = string
  default     = "t3.micro"
}

variable "bastion_user_data" {
  description = "User data script for the bastion host."
  type        = string
  default     = null # Or provide a default script path/content
  # Example default using file function:
  # default = file("${path.module}/templates/bastion_userdata.sh")
}
