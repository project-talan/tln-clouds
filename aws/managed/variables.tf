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

variable "aws_k8s_version" {
  type = string
}
variable "aws_k8s_node_groups" {
  description = "K8s node groups details"
  type = map(object({
    name = string,
    instance_types = list(string)
    min_size = number
    desired_size = number
    max_size = number
    disk_size = number
  }))
  default = {
    "ng1": {
      "name": "ng1",
      "instance_types": ["t3.small"],
      "min_size": 1,
      "desired_size": 2,
      "max_size": 3,
      "disk_size": 20
    },
    "ng2": {
      "name": "ng2",
      "instance_types": ["t3.medium"],
      "min_size": 1,
      "desired_size": 2,
      "max_size": 3,
      "disk_size": 20
    }
  }
}
