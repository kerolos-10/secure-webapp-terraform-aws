variable "instance_type" {
  type        = string
  default     = "t2.micro"
}

variable "subnet_id" {
  type        = string
}

variable "security_group_id" {
  type        = string
}

variable "key_name" {
  type        = string
}

variable "private_key_path" {
  type        = string
}
