variable "name" {}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {}

variable "vpc_id" {}

variable "target_group_name" {}

variable "target_port" {}

variable "listener_port" {}

variable "target_instance_ids" {
  type = list(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
