variable "vpc_id" {
  description = "The VPC ID where the NAT Gateway will be created"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "public_subnet_id" {
  description = "The subnet ID for the public subnet where the NAT Gateway will be placed"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of subnet IDs for the private subnets that will route through the NAT Gateway"
  type        = list(string)
}

variable "environment" {
  description = "Environment for tagging"
  type        = string
  default     = "development"
}
