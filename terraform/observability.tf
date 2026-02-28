resource "aws_cloudwatch_log_group" "application" {
  name              = "/${var.project_name}/application"
  retention_in_days = 14

  tags = {
    Name = "${var.project_name}-cw-log-group"
  }
}

resource "aws_sns_topic" "security_alerts" {
  name = "${var.project_name}-security-alerts"

  tags = {
    Name = "${var.project_name}-security-alerts"
  }
}

resource "aws_sns_topic_subscription" "security_alerts_email" {
  count     = var.alert_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}

resource "aws_cloudwatch_log_metric_filter" "security_events" {
  name           = "${var.project_name}-security-events-filter"
  log_group_name = aws_cloudwatch_log_group.application.name

  pattern = "%Unauthorized|AccessDenied|Failed|Invalid token|Brute force%"

  metric_transformation {
    name      = "SecurityEventsCount"
    namespace = "${var.project_name}/Security"
    value     = "1"
  }
}

resource "aws_cloudwatch_metric_alarm" "security_events_high" {
  alarm_name          = "${var.project_name}-security-events-high"
  alarm_description   = "Detecta pico de eventos de seguranca"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  threshold           = 5
  period              = 300
  statistic           = "Sum"
  namespace           = "${var.project_name}/Security"
  metric_name         = "SecurityEventsCount"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.security_alerts.arn]
  ok_actions    = [aws_sns_topic.security_alerts.arn]
}

resource "aws_cloudwatch_metric_alarm" "log_ingestion_stopped" {
  alarm_name          = "${var.project_name}-log-ingestion-stopped"
  alarm_description   = "Sem novos eventos no log group da aplicacao"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 3
  threshold           = 0
  period              = 500
  statistic           = "Sum"
  namespace           = "AWS/Logs"
  metric_name         = "IncomingLogEvents"
  treat_missing_data  = "breaching"

  dimensions = {
    LogGroupName = aws_cloudwatch_log_group.application.name
  }

  alarm_actions = [aws_sns_topic.security_alerts.arn]
  ok_actions    = [aws_sns_topic.security_alerts.arn]
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
  alarm_description   = "CPU alta na camada de aplicacao"

  dimensions = {
    InstanceId = aws_instance.frontend[0].id
  }
}
