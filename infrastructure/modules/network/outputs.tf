output "vpc_id" {
  description = "ID of the VPC created by the network module."
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "IPv4 CIDR block assigned to the VPC."
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs keyed by subnet name."
  value       = { for name, subnet in aws_subnet.public : name => subnet.id }
}

output "private_subnet_ids" {
  description = "Private subnet IDs keyed by subnet name."
  value       = { for name, subnet in aws_subnet.private : name => subnet.id }
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "private_route_table_id" {
  description = "ID of the private route table."
  value       = aws_route_table.private.id
}

output "alb_security_group_id" {
  description = "ID of the application load balancer security group."
  value       = aws_security_group.alb.id
}

output "api_security_group_id" {
  description = "ID of the private API security group."
  value       = aws_security_group.api.id
}
