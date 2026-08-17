variable "project_name" {
  description = "Project name used when naming GitHub Actions IAM resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment that GitHub Actions publishes images for."
  type        = string
}

variable "github_repository_owner" {
  description = "GitHub account that owns the repository."
  type        = string
}

variable "github_repository_owner_id" {
  description = "Immutable numeric ID of the GitHub repository owner."
  type        = string
}

variable "github_repository_name" {
  description = "GitHub repository allowed to request AWS credentials."
  type        = string
}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository."
  type        = string
}

variable "github_branch" {
  description = "GitHub branch allowed to publish container images."
  type        = string
  default     = "main"
}

variable "ecr_repository_arn" {
  description = "ARN of the only ECR repository GitHub Actions may publish to."
  type        = string
}
