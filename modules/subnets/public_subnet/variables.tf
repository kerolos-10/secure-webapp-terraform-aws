variable "vpc_id" {
  description = "The VPC ID where the subnets will be created"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for the public subnets"
  type        = list(string)
}


variable "environment" {
  description = "Environment for tagging"
  type        = string
  default     = "development"
}
