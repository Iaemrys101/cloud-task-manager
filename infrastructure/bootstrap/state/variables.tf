variable "aws_region" {
  description = "AWS Region where the Terraform state bucket is stored."
  type        = string
  default     = "eu-west-2"
}

variable "project_name" {
  description = "Project name used when naming and tagging the state bucket."
  type        = string
  default     = "cloud-task-manager"
}
