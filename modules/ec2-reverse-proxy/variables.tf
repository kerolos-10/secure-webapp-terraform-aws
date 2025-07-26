variable "public_subnet_id" {
  description = "The subnet ID for the public subnet where the NAT Gateway will be placed"
  type        = list(string)
}

variable "security_group_id" {
  description = "Security group to attach to the proxy EC2 instances"
  type        = string
}

variable "key_name" {
  description = "EC2 key pair name"
  type        = string
}

variable "private_key_path" {
  description = "Path to private key file for SSH"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "backend_target" {
  description = "The backend target (IP or internal ALB DNS) for proxy_pass"
  type        = string
}
