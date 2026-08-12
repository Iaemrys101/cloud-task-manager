output "cluster_name" {
  description = "Name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "service_name" {
  description = "Name of the ECS backend service."
  value       = aws_ecs_service.backend.name
}

output "load_balancer_dns_name" {
  description = "DNS name assigned to the application load balancer."
  value       = aws_lb.backend.dns_name
}

output "target_group_arn" {
  description = "ARN of the backend load balancer target group."
  value       = aws_lb_target_group.backend.arn
}
