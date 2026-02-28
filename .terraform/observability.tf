resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/application"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-cw-log-group"
  }
}

resource "aws_cloudwatch_metric_alarm" "app_cpu_high" {
  alarm_name          = "${var.project_name}-app-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "CPU alta na camada de aplicação"

  dimensions = {
    InstanceId = aws_instance.frontend[0].id
  }
}
