resource "aws_security_group" "alb" {
  name        = "${var.project_name}-${var.environment}-alb-sg"
  description = "Controls traffic for the public application load balancer."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  }
}

resource "aws_security_group" "api" {
  name        = "${var.project_name}-${var.environment}-api-sg"
  description = "Controls traffic for the private API service."
  vpc_id      = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-${var.environment}-api-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id
  description       = "Allow public HTTP traffic to the load balancer."

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "alb_to_api" {
  security_group_id            = aws_security_group.alb.id
  referenced_security_group_id = aws_security_group.api.id
  description                  = "Allow the load balancer to reach the API."

  from_port   = 8000
  ip_protocol = "tcp"
  to_port     = 8000
}

resource "aws_vpc_security_group_ingress_rule" "api_from_alb" {
  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.alb.id
  description                  = "Allow API traffic only from the load balancer."

  from_port   = 8000
  ip_protocol = "tcp"
  to_port     = 8000
}

resource "aws_vpc_security_group_egress_rule" "api_to_service_endpoints" {
  count = var.enable_container_endpoints ? 1 : 0

  security_group_id            = aws_security_group.api.id
  referenced_security_group_id = aws_security_group.service_endpoints[0].id
  description                  = "Allow the API to reach private AWS service endpoints over HTTPS."

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}

resource "aws_vpc_security_group_egress_rule" "api_to_s3" {
  count = var.enable_container_endpoints ? 1 : 0

  security_group_id = aws_security_group.api.id
  prefix_list_id    = aws_vpc_endpoint.s3[0].prefix_list_id
  description       = "Allow the API to retrieve ECR image layers from S3 over HTTPS."

  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443
}
