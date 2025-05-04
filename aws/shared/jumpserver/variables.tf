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
variable "jumpserver_volume_size" {
  description = "The size of the EBS volume for the jump server instance."
  type        = number
  default     = 30
}
variable "ami_name" {
  description = "AMI Name to use for the EC2 instance of the jump server"
  type        = string
  default     = "ubuntu-minimal/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-minimal-*"
}
variable "custom_packages" {
  type = map(string)
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
