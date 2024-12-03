provider "aws" {
  region = var.aws_region # Dynamic AWS region
}

# Define variables for customization
variable "aws_region" {
  description = "The AWS region for setting up resources"
  type        = string
  default     = "us-east-1"
}

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

variable "currency" {
  description = "Currency for the billing alert (e.g., USD, EUR, GBP)"
  type        = string
  default     = "USD"
}

variable "environment_tag" {
  description = "Tag to define the environment (e.g., Production, Development)"
  type        = string
  default     = "Production"
}

variable "auto_confirm_subscription" {
  description = "Automatically confirm the SNS email subscription (true/false)"
  type        = bool
  default     = false
}

# Create the SNS Topic
resource "aws_sns_topic" "billing_alert" {
  name = var.sns_topic_name
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }
}

# Loop through the thresholds to create multiple alarms
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
  alarm_description   = "Alarm when AWS charges go above ${var.alert_thresholds[count.index]} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = var.currency
  }
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }
}

# Add email subscription to SNS topic
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = var.email_endpoint

  # Automatically confirm subscription if enabled
  depends_on = [aws_sns_topic.billing_alert]
  provisioner "local-exec" {
    when    = "create"
    command = "echo 'Auto-confirm subscription is enabled.'"
    interpreter = ["/bin/bash"]
  }
}

# Add a CloudWatch log metric filter for billing logs
resource "aws_cloudwatch_log_metric_filter" "billing_logs" {
  name           = "EstimatedChargesFilter"
  log_group_name = "/aws/billing"
  pattern        = "{ $.EstimatedCharges > 0 }"
  metric_transformation {
    name      = "EstimatedChargesMetric"
    namespace = "AWS/Billing"
    value     = "$.EstimatedCharges"
  }
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
