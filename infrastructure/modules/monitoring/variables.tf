variable "project_name" {
  description = "Project name used when naming monitoring resources."
  type        = string
}

variable "environment" {
  description = "Deployment environment monitored by this module."
  type        = string
}

variable "aws_region" {
  description = "AWS Region containing the monitored resources."
  type        = string
}

variable "ecs_cluster_name" {
  description = "Name of the ECS cluster to monitor."
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS service to monitor."
  type        = string
}

variable "load_balancer_arn_suffix" {
  description = "CloudWatch dimension value for the application load balancer."
  type        = string
}

variable "target_group_arn_suffix" {
  description = "CloudWatch dimension value for the backend target group."
  type        = string
}

variable "log_group_name" {
  description = "CloudWatch log group containing backend application logs."
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "memory_alarm_threshold" {
  description = "Memory utilization percentage that triggers an alarm."
  type        = number
  default     = 80
}

variable "latency_alarm_threshold_seconds" {
  description = "Average response time in seconds that triggers an alarm."
  type        = number
  default     = 1
}

variable "server_error_alarm_threshold" {
  description = "Number of target HTTP 5xx responses that triggers an alarm."
  type        = number
  default     = 5
}
