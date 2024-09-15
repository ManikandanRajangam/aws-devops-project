resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high_cpu_usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [
    "arn:aws:sns:ap-south-1:123456789012:my-sns-topic"
  ]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}
