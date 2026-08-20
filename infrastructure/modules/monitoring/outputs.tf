output "dashboard_name" {
  description = "Name of the CloudWatch operations dashboard."
  value       = aws_cloudwatch_dashboard.main.dashboard_name
}

output "alert_topic_arn" {
  description = "ARN of the SNS topic that receives CloudWatch alarm notifications."
  value       = aws_sns_topic.alerts.arn
}

output "alarm_names" {
  description = "Names of the CloudWatch alarms created for the backend service."
  value = {
    cpu               = aws_cloudwatch_metric_alarm.ecs_cpu_high.alarm_name
    memory            = aws_cloudwatch_metric_alarm.ecs_memory_high.alarm_name
    target_5xx        = aws_cloudwatch_metric_alarm.target_5xx_high.alarm_name
    target_latency    = aws_cloudwatch_metric_alarm.target_latency_high.alarm_name
    unhealthy_targets = aws_cloudwatch_metric_alarm.unhealthy_targets.alarm_name
  }
}
