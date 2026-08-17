variable "aws_region" {
  description = "AWS Region where the development infrastructure is managed."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used when naming and tagging AWS resources."
  type        = string
  default     = "cloud-task-manager"
}

variable "environment" {
  description = "Deployment environment represented by this Terraform root module."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "github_repository_owner" {
  description = "GitHub account that owns the project repository."
  type        = string
  default     = "Iaemrys101"
}

variable "github_repository_owner_id" {
  description = "Immutable numeric ID of the GitHub repository owner."
  type        = string
  default     = "278219135"
}

variable "github_repository_name" {
  description = "GitHub repository allowed to publish backend images."
  type        = string
  default     = "cloud-task-manager"
}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository."
  type        = string
  default     = "1302127730"
}

variable "github_publish_branch" {
  description = "GitHub branch allowed to obtain AWS publishing credentials."
  type        = string
  default     = "main"
}

variable "deploy_container_runtime" {
  description = "Whether to deploy the billable ECS, ALB, logging, and VPC endpoint runtime."
  type        = bool
  default     = false
}

variable "container_image_tag" {
  description = "Immutable ECR image tag deployed by the ECS service."
  type        = string
  default     = ""

  validation {
    condition     = !var.deploy_container_runtime || length(trimspace(var.container_image_tag)) > 0
    error_message = "container_image_tag must be set when deploy_container_runtime is true."
  }
}

variable "vpc_cidr" {
  description = "IPv4 CIDR block assigned to the development VPC."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "VPC CIDR must be a valid IPv4 CIDR block."
  }
}

variable "public_subnets" {
  description = "Public subnet CIDRs and Availability Zones for the development VPC."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    public-a = {
      cidr_block        = "10.0.1.0/24"
      availability_zone = "eu-west-2a"
    }
    public-b = {
      cidr_block        = "10.0.2.0/24"
      availability_zone = "eu-west-2b"
    }
  }

  validation {
    condition = length(var.public_subnets) == 2 && alltrue([
      for subnet in values(var.public_subnets) : can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Exactly two public subnets with valid IPv4 CIDR blocks are required."
  }
}

variable "private_subnets" {
  description = "Private subnet CIDRs and Availability Zones for the development VPC."
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))

  default = {
    private-a = {
      cidr_block        = "10.0.11.0/24"
      availability_zone = "eu-west-2a"
    }
    private-b = {
      cidr_block        = "10.0.12.0/24"
      availability_zone = "eu-west-2b"
    }
  }

  validation {
    condition = length(var.private_subnets) == 2 && alltrue([
      for subnet in values(var.private_subnets) : can(cidrnetmask(subnet.cidr_block))
    ])
    error_message = "Exactly two private subnets with valid IPv4 CIDR blocks are required."
  }
}
