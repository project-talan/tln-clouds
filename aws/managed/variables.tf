variable "org_id"     { type = string }
variable "project_id" { type = string }
variable "group_id"   { type = string }
variable "env_id"     { type = string }
variable "tenant_id"  { type = string }

variable "aws_k8s_version" { type = string }
variable "aws_k8s_nodes_min" { type = string }
variable "aws_k8s_nodes_desired" { type = string }
variable "aws_k8s_nodes_max" { type = string }
variable "aws_k8s_nodes_size" { type = string }
variable "aws_k8s_nodes_disk" { type = string }
