provider "aws" {
  region = "us-east-1" # AWS Billing metric is only available in us-east-1
}

# Define variables for customization
variable "sns_topic_name" {
  description = "The name of the SNS topic for billing alerts"
  type        = string
  default     = "billing-alert"
}

variable "alert_thresholds" {
  description = "List of billing thresholds to create alarms for"
  type        = list(number)
  default     = [100, 120] # Default thresholds in USD
}

variable "email_endpoint" {
  description = "The email address to receive billing alerts"
  type        = string
  default     = "your-email@example.com" # Replace with your email
}

resource "aws_sns_topic" "billing_alert" {
  name = var.sns_topic_name
  tags = {
    Environment = "Production"
    Purpose     = "BillingAlerts"
  }
}

# Loop through the list of thresholds to create multiple alarms
resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  count               = length(var.alert_thresholds)
  alarm_name          = "estimated-charges-${var.alert_thresholds[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours in seconds
  statistic           = "Maximum"
  threshold           = var.alert_thresholds[count.index]
  alarm_description   = "Alarm when AWS charges go above ${var.alert_thresholds[count.index]} USD"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = "USD"
  }
  tags = {
    Environment = "Production"
    Purpose     = "BillingAlerts"
  }
}

resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = var.email_endpoint

  # Optional: Automatically confirm the subscription (useful for testing)
  # Depends on permissions and environment setup
  depends_on = [aws_sns_topic.billing_alert]
}

# Outputs for easier management and monitoring
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alert.arn
}

output "cloudwatch_alarm_names" {
  description = "List of CloudWatch alarm names"
  value       = [for alarm in aws_cloudwatch_metric_alarm.estimated_charges : alarm.alarm_name]
}
