terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  common_tags = {
    Environment = var.environment_tag
    Purpose     = "BillingAlerts"
  }

  unique_alert_thresholds = toset(var.alert_thresholds)
}

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
  default     = [100, 120]

  validation {
    condition     = length(var.alert_thresholds) > 0 && alltrue([for threshold in var.alert_thresholds : threshold > 0])
    error_message = "alert_thresholds must contain at least one positive number."
  }
}

variable "email_endpoints" {
  description = "List of email addresses to receive billing alerts"
  type        = list(string)
  default     = ["your-email@example.com"]

  validation {
    condition = alltrue([
      for email in var.email_endpoints : can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", email))
    ])
    error_message = "Each value in email_endpoints must be a valid email address."
  }
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

resource "aws_sns_topic" "billing_alert" {
  name = var.sns_topic_name
  tags = local.common_tags
}

resource "aws_sqs_queue" "sns_dlq" {
  name = "${var.sns_topic_name}-dlq"
  tags = local.common_tags
}

resource "aws_sqs_queue_policy" "sns_dlq" {
  queue_url = aws_sqs_queue.sns_dlq.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowSNSToSendMessages"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.sns_dlq.arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.billing_alert.arn
          }
        }
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "sns_dlq_subscription" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sns_dlq.arn
}

resource "aws_cloudwatch_metric_alarm" "estimated_charges" {
  for_each            = local.unique_alert_thresholds
  alarm_name          = "estimated-charges-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400
  statistic           = "Maximum"
  threshold           = each.value
  alarm_description   = "Alarm when AWS charges exceed ${each.value} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = var.currency
  }
  tags = local.common_tags
}

resource "aws_cloudwatch_metric_alarm" "service_billing_alert" {
  for_each            = local.unique_alert_thresholds
  alarm_name          = "service-billing-alert-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = 86400
  statistic           = "Maximum"
  threshold           = each.value
  alarm_description   = "Alarm when AWS service-specific charges exceed ${each.value} ${var.currency}"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    ServiceName = "AmazonEC2"
    Currency    = var.currency
  }
  tags = local.common_tags
}

resource "aws_sns_topic_subscription" "email_alerts" {
  for_each                = toset(var.email_endpoints)
  topic_arn               = aws_sns_topic.billing_alert.arn
  protocol                = "email"
  endpoint                = each.value
  endpoint_auto_confirms  = var.auto_confirm_subscription
  confirmation_timeout_in_minutes = 5
}

resource "aws_cloudwatch_dashboard" "billing" {
  dashboard_name = "${var.sns_topic_name}-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 24
        height = 6
        properties = {
          title   = "Estimated Charges (${var.currency})"
          region  = "us-east-1"
          stat    = "Maximum"
          period  = 86400
          view    = "timeSeries"
          metrics = [["AWS/Billing", "EstimatedCharges", "Currency", var.currency]]
        }
      }
    ]
  })
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alert.arn
}

output "cloudwatch_alarm_names" {
  description = "List of CloudWatch alarm names"
  value       = [for alarm in aws_cloudwatch_metric_alarm.estimated_charges : alarm.alarm_name]
}

output "sns_dlq_arn" {
  description = "The ARN of the SNS dead-letter queue"
  value       = aws_sqs_queue.sns_dlq.arn
}

output "billing_dashboard_name" {
  description = "The CloudWatch dashboard name for billing visibility"
  value       = aws_cloudwatch_dashboard.billing.dashboard_name
}
