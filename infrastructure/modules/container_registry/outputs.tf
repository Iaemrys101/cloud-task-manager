output "repository_arn" {
  description = "ARN of the backend ECR repository."
  value       = aws_ecr_repository.backend.arn
}

output "repository_name" {
  description = "Name of the backend ECR repository."
  value       = aws_ecr_repository.backend.name
}

output "repository_url" {
  description = "URL used when tagging and pushing backend container images."
  value       = aws_ecr_repository.backend.repository_url
}
