resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-${var.environment}-operations"

  dashboard_body = jsonencode({
    start          = "-PT8H"
    periodOverride = "inherit"

    widgets = [
      {
        type   = "alarm"
        x      = 0
        y      = 0
        width  = 24
        height = 6

        properties = {
          title  = "Service alarm status"
          sortBy = "stateUpdatedTimestamp"
          alarms = [
            aws_cloudwatch_metric_alarm.ecs_cpu_high.arn,
            aws_cloudwatch_metric_alarm.ecs_memory_high.arn,
            aws_cloudwatch_metric_alarm.target_5xx_high.arn,
            aws_cloudwatch_metric_alarm.target_latency_high.arn,
            aws_cloudwatch_metric_alarm.unhealthy_targets.arn
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "ECS CPU and memory utilization"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          stacked = false
          yAxis = {
            left = {
              min = 0
              max = 100
            }
          }
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { label = "CPU", stat = "Average" }],
            ["AWS/ECS", "MemoryUtilization", "ClusterName", var.ecs_cluster_name, "ServiceName", var.ecs_service_name, { label = "Memory", stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6

        properties = {
          title   = "Requests and backend 5xx errors"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "RequestCount", "LoadBalancer", var.load_balancer_arn_suffix, { label = "Requests", stat = "Sum" }],
            ["AWS/ApplicationELB", "HTTPCode_Target_5XX_Count", "LoadBalancer", var.load_balancer_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { label = "Backend 5xx", stat = "Sum", yAxis = "right" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 12
        width  = 12
        height = 6

        properties = {
          title   = "Backend response latency"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", var.load_balancer_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { label = "Average response time", stat = "Average" }]
          ]
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 12
        width  = 12
        height = 6

        properties = {
          title   = "Load balancer target health"
          view    = "timeSeries"
          region  = var.aws_region
          period  = 60
          stacked = false
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", var.load_balancer_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { label = "Healthy targets", stat = "Average" }],
            ["AWS/ApplicationELB", "UnHealthyHostCount", "LoadBalancer", var.load_balancer_arn_suffix, "TargetGroup", var.target_group_arn_suffix, { label = "Unhealthy targets", stat = "Maximum" }]
          ]
        }
      },
      {
        type   = "log"
        x      = 0
        y      = 18
        width  = 24
        height = 6

        properties = {
          title  = "Recent backend errors"
          region = var.aws_region
          view   = "table"
          query  = "SOURCE '${var.log_group_name}' | fields @timestamp, @message | filter @message like /ERROR|Exception/ | sort @timestamp desc | limit 20"
        }
      }
    ]
  })
}
