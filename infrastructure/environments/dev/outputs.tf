output "vpc_id" {
  description = "ID of the development VPC."
  value       = module.network.vpc_id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the development VPC."
  value       = module.network.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by subnet name."
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by subnet name."
  value       = module.network.private_subnet_ids
}

output "public_route_table_id" {
  description = "ID of the development public route table."
  value       = module.network.public_route_table_id
}

output "private_route_table_id" {
  description = "ID of the development private route table."
  value       = module.network.private_route_table_id
}

output "alb_security_group_id" {
  description = "ID of the development load balancer security group."
  value       = module.network.alb_security_group_id
}

output "api_security_group_id" {
  description = "ID of the development API security group."
  value       = module.network.api_security_group_id
}

output "ecr_repository_name" {
  description = "Name of the development backend ECR repository."
  value       = module.container_registry.repository_name
}

output "ecr_repository_url" {
  description = "URL used to tag and push development backend images."
  value       = module.container_registry.repository_url
}

output "github_actions_role_arn" {
  description = "IAM role assumed by GitHub Actions through OIDC."
  value       = module.github_actions_oidc.role_arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster when the container runtime is deployed."
  value       = try(module.container_service[0].cluster_name, null)
}

output "ecs_service_name" {
  description = "Name of the ECS service when the container runtime is deployed."
  value       = try(module.container_service[0].service_name, null)
}

output "application_url" {
  description = "Temporary HTTP URL of the development load balancer."
  value       = try("http://${module.container_service[0].load_balancer_dns_name}", null)
}

output "monitoring_dashboard_name" {
  description = "Name of the CloudWatch operations dashboard when monitoring is deployed."
  value       = try(module.monitoring[0].dashboard_name, null)
}

output "monitoring_alert_topic_arn" {
  description = "ARN of the SNS alert topic when monitoring is deployed."
  value       = try(module.monitoring[0].alert_topic_arn, null)
}

output "monitoring_alarm_names" {
  description = "CloudWatch alarm names when monitoring is deployed."
  value       = try(module.monitoring[0].alarm_names, null)
}
