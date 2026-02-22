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

variable "email_endpoints" {
  description = "List of email addresses to receive billing alerts"
  type        = list(string)
  default     = ["your-email@example.com"] # Replace with actual emails
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

# SNS Topic for Billing Alerts
resource "aws_sns_topic" "billing_alert" {
  name = var.sns_topic_name
  
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }
}

# SNS Topic Policy to allow CloudWatch to publish alerts
resource "aws_sns_topic_policy" "billing_alert_policy" {
  arn = aws_sns_topic.billing_alert.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { "Service" = "cloudwatch.amazonaws.com" }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.billing_alert.arn
      },
      {
        Effect    = "Allow"
        Principal = { "AWS" = "*" }
        Action    = "sns:Subscribe"
        Resource  = aws_sns_topic.billing_alert.arn
        Condition = {
          StringEquals = {
            "sns:Protocol" = "email"
          }
        }
      }
    ]
  })
}

# SNS Dead-Letter Queue (DLQ) for failed notifications
resource "aws_sqs_queue" "sns_dlq" {
  name                        = "${var.sns_topic_name}-dlq"
  message_retention_seconds   = 1209600 # 14 days
  visibility_timeout_seconds  = 300
  
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlertsDLQ"
  }
}

# SQS Queue Policy to allow SNS to send messages to DLQ
resource "aws_sqs_queue_policy" "sns_dlq_policy" {
  queue_url = aws_sqs_queue.sns_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { "Service" = "sns.amazonaws.com" }
        Action    = ["sqs:SendMessage"]
        Resource  = aws_sqs_queue.sns_dlq.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "sns_dlq_subscription" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sns_dlq.arn
  
  depends_on = [aws_sqs_queue_policy.sns_dlq_policy]
}

# CloudWatch Billing Alarms (Total)
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
  alarm_description   = "Alarm when AWS charges exceed ${var.alert_thresholds[count.index]} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  ok_actions          = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    Currency = var.currency
  }
  
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
    Threshold   = "${var.alert_thresholds[count.index]}"
  }
  
  depends_on = [aws_sns_topic_policy.billing_alert_policy]
}

# Billing Alerts per AWS Service
resource "aws_cloudwatch_metric_alarm" "service_billing_alert" {
  count               = length(var.alert_thresholds)
  alarm_name          = "service-billing-alert-AmazonEC2-${var.alert_thresholds[count.index]}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400"
  statistic           = "Maximum"
  threshold           = var.alert_thresholds[count.index]
  alarm_description   = "Alarm when AmazonEC2 charges exceed ${var.alert_thresholds[count.index]} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  ok_actions          = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    ServiceName = "AmazonEC2"
    Currency    = var.currency
  }
  
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
    Service     = "AmazonEC2"
    Threshold   = "${var.alert_thresholds[count.index]}"
  }
  
  depends_on = [aws_sns_topic_policy.billing_alert_policy]
}

# Add multiple email subscriptions to SNS topic
resource "aws_sns_topic_subscription" "email_alerts" {
  count     = length(var.email_endpoints)
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = var.email_endpoints[count.index]
}

# CloudWatch Log Metric Filter for Billing Logs
resource "aws_cloudwatch_log_metric_filter" "billing_logs" {
  name           = "EstimatedChargesFilter"
  log_group_name = "/aws/billing"
  pattern        = "{ $.EstimatedCharges > 0 }"
  metric_transformation {
    name      = "EstimatedChargesMetric"
    namespace = "AWS/Billing"
    value     = "$.EstimatedCharges"
  }
  
  tags = {
    Environment = var.environment_tag
    Purpose     = "BillingFilter"
  }
}

