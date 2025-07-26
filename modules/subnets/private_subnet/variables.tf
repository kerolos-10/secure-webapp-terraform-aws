variable "vpc_id" {
  description = "The VPC ID where the subnets will be created"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}


variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for the private subnets"
  type        = list(string)
}

variable "environment" {
  description = "Environment for tagging"
  type        = string
  default     = "development"
}
