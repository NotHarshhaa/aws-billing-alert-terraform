# ==============================================================================
# Outputs for AWS Billing Alert Module
# ==============================================================================

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alert.arn
}

output "sns_topic_name" {
  description = "The name of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alert.name
}

output "cloudwatch_alarm_names" {
  description = "List of CloudWatch alarm names for total charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.estimated_charges : alarm.alarm_name]
}

output "cloudwatch_alarm_arns" {
  description = "List of CloudWatch alarm ARNs for total charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.estimated_charges : alarm.arn]
}

output "service_alarm_names" {
  description = "List of CloudWatch alarm names for per-service charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.service_billing_alert : alarm.alarm_name]
}

output "service_alarm_arns" {
  description = "List of CloudWatch alarm ARNs for per-service charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.service_billing_alert : alarm.arn]
}

output "sns_dlq_arn" {
  description = "The ARN of the alert SQS queue (if enabled)"
  value       = try(aws_sqs_queue.sns_dlq[0].arn, null)
}

output "sns_dlq_url" {
  description = "The URL of the alert SQS queue (if enabled)"
  value       = try(aws_sqs_queue.sns_dlq[0].id, null)
}

output "email_endpoints" {
  description = "List of email addresses configured for billing alerts"
  value       = var.email_endpoints
}

output "email_subscription_count" {
  description = "Number of email subscriptions configured"
  value       = length(var.email_endpoints)
}

output "configuration_summary" {
  description = "Summary of billing alert configuration"
  value = {
    aws_region         = var.aws_region
    currency           = var.currency
    thresholds         = var.alert_thresholds
    email_count        = length(var.email_endpoints)
    environment        = var.environment_tag
    monitored_services = var.services_to_monitor
    alarm_period       = var.alarm_period
    ok_actions_enabled = var.enable_ok_actions
    sqs_queue_enabled  = var.enable_sqs_endpoint
  }
}
