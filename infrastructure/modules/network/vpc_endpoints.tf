locals {
  container_interface_endpoint_services = toset([
    "ecr.api",
    "ecr.dkr",
    "logs",
  ])
}

resource "aws_security_group" "service_endpoints" {
  count = var.enable_container_endpoints ? 1 : 0

  name        = "${var.project_name}-${var.environment}-endpoints-sg"
  description = "Controls HTTPS access to private AWS service endpoints."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-endpoints-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "service_endpoints_https" {
  count = var.enable_container_endpoints ? 1 : 0

  security_group_id            = aws_security_group.service_endpoints[0].id
  referenced_security_group_id = aws_security_group.api.id
  description                  = "Allow private ECS tasks to reach AWS services over HTTPS."

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_endpoint" "container_interface" {
  for_each = var.enable_container_endpoints ? local.container_interface_endpoint_services : toset([])

  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids         = [for subnet in aws_subnet.private : subnet.id]
  security_group_ids = [aws_security_group.service_endpoints[0].id]

  tags = {
    Name = "${var.project_name}-${var.environment}-${replace(each.value, ".", "-")}-endpoint"
  }
}

resource "aws_vpc_endpoint" "s3" {
  count = var.enable_container_endpoints ? 1 : 0

  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]

  tags = {
    Name = "${var.project_name}-${var.environment}-s3-endpoint"
  }
}
