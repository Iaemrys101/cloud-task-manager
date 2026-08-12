variable "environment" {
  description = "Deployment environment that owns the network."
  type        = string
}

variable "aws_region" {
  description = "AWS Region used to construct regional VPC endpoint service names."
  type        = string
}

variable "enable_container_endpoints" {
  description = "Whether to create private AWS service endpoints required by ECS tasks."
  type        = bool
  default     = false
}

variable "project_name" {
  description = "Project name used when naming network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the VPC."
  type        = string

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "Public subnet CIDRs and Availability Zones."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  validation {
    condition = length(var.public_subnets) == 2 && alltrue([
      for subnet in values(var.public_subnets) : can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Exactly two public subnets with valid IPv4 CIDR blocks are required."
  }
}

variable "private_subnets" {
  description = "Private subnet CIDRs and Availability Zones."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  validation {
    condition = length(var.private_subnets) == 2 && alltrue([
      for subnet in values(var.private_subnets) : can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Exactly two private subnets with valid IPv4 CIDR blocks are required."
  }
}
