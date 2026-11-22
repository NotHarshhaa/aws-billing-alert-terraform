# ==============================================================================
# CloudWatch Billing Alarms (Total Estimated Charges)
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  for_each            = toset([for t in var.alert_thresholds : tostring(t)])
  alarm_name          = "estimated-charges-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = tonumber(each.value)
  alarm_description   = "Alarm when AWS total charges exceed ${each.value} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  ok_actions          = var.enable_ok_actions ? [aws_sns_topic.billing_alert.arn] : []
  treat_missing_data  = "notBreaching"

  dimensions = {
    Currency = var.currency
  }

  tags = merge(
    local.common_tags,
    {
      Purpose   = "BillingAlerts"
      Threshold = each.value
      Scope     = "Total"
    }
  )

  depends_on = [aws_sns_topic_policy.billing_alert_policy]
}

# ==============================================================================
# CloudWatch Billing Alarms (Per-Service Estimated Charges)
# ==============================================================================

resource "aws_cloudwatch_metric_alarm" "service_billing_alert" {
  for_each            = { for item in local.service_alarms : item.key => item }
  alarm_name          = "service-billing-alert-${each.value.service}-${each.value.threshold}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = var.alarm_period
  statistic           = "Maximum"
  threshold           = each.value.threshold
  alarm_description   = "Alarm when ${each.value.service} charges exceed ${each.value.threshold} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  ok_actions          = var.enable_ok_actions ? [aws_sns_topic.billing_alert.arn] : []
  treat_missing_data  = "notBreaching"

  dimensions = {
    ServiceName = each.value.service
    Currency    = var.currency
  }

  tags = merge(
    local.common_tags,
    {
      Purpose   = "BillingAlerts"
      Service   = each.value.service
      Threshold = tostring(each.value.threshold)
      Scope     = "Service"
    }
  )

  depends_on = [aws_sns_topic_policy.billing_alert_policy]
}
