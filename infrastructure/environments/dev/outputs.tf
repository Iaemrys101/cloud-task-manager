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
