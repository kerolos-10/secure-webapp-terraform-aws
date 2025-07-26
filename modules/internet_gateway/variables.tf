variable "vpc_id" {
  description = "The ID of the VPC where the internet gateway will be attached"
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "name" {
  description = "The name tag for the Internet Gateway"
  type        = string
}

variable "route_table_name" {
  description = "The name tag for the route table"
  type        = string
}

variable "environment" {
  description = "The environment in which this resource is deployed (e.g. production, staging)"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of subnet IDs for the public subnet where the NAT Gateway will be placed"
  type        = list(string)
}