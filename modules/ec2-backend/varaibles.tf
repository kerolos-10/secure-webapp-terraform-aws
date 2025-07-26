variable "private_subnet_id" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "security_group_id" {
  type        = string
  description = "SG for backend that allows 5000"
}

variable "key_name" {
  type        = string
}

variable "private_key_path" {
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

variable "bastion_host" {
  type        = string
  description = "Public IP of bastion host (reverse proxy)"
}
