output "role_arn" {
  description = "ARN of the IAM role assumed by GitHub Actions through OIDC."
  value       = aws_iam_role.ecr_publisher.arn
}
