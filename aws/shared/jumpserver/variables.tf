variable "resources_prefix" {
  description = "Prefix for resource names to ensure uniqueness."
  type        = string
}

variable "files_prefix" {
  description = "Prefix for local file names to ensure uniqueness."
  type        = string
}

variable "vpc_id" {
  description = "The VPC ID where the jump server and security group will be created."
  type        = string
}

variable "subnet_id" {
  description = "The public subnet ID where the jump server instance will be launched."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type for the jump server."
  type        = string
  default     = "t3.micro"
}

variable "ami_id" {
  description = "Optional specific AMI ID to use for the jump server. If null, the latest Ubuntu 22.04 LTS AMI will be used."
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script to run on the instance at launch."
  type        = string
  default     = null
}

variable "allowed_ssh_cidr_blocks" {
  description = "List of CIDR blocks allowed to SSH into the jump server."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  description = "A map of tags to assign to the resources."
  type        = map(string)
  default     = {}
}
