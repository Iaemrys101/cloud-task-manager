variable "project_name" {
  description = "Project name used when naming the container repository."
  type        = string
}

variable "environment" {
  description = "Deployment environment that owns the container repository."
  type        = string
}
