resource "aws_sns_topic" "alerts" {
  name = "${var.project_name}-${var.environment}-alerts"

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-alerts"
  })
}

resource "aws_cloudwatch_metric_alarm" "lambda_errors" {
  for_each = var.lambda_function_names

  alarm_name          = "${var.project_name}-${var.environment}-${each.key}-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = 60
  statistic           = "Sum"
  threshold           = 1

  dimensions = {
    FunctionName = each.value
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
}
