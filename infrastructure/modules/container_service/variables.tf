variable "project_name" {
  description = "Project name used when naming container service resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment that owns the container service."
  type        = string
}

variable "aws_region" {
  description = "AWS Region used by the ECS task logging configuration."
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC that hosts the load balancer and ECS tasks."
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs used by the internet-facing load balancer."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least two public subnets are required for the load balancer."
  }
}

variable "private_subnet_ids" {
  description = "Private subnet IDs used by the Fargate service."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_ids) >= 2
    error_message = "At least two private subnets are required for the Fargate service."
  }
}

variable "alb_security_group_id" {
  description = "Security group ID attached to the application load balancer."
  type        = string
}

variable "api_security_group_id" {
  description = "Security group ID attached to the private Fargate tasks."
  type        = string
}

variable "container_image" {
  description = "Complete ECR image reference, including its immutable tag."
  type        = string
}

variable "container_port" {
  description = "Port exposed by the FastAPI container."
  type        = number
  default     = 8000
}

variable "task_cpu" {
  description = "Fargate CPU units allocated to each task."
  type        = number
  default     = 256
}

variable "task_memory" {
  description = "Fargate memory in MiB allocated to each task."
  type        = number
  default     = 512
}

variable "desired_count" {
  description = "Number of backend tasks maintained by the ECS service."
  type        = number
  default     = 1
}
