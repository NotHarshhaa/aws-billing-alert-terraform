# Outputs for easier management and monitoring
output "sns_topic_arn" {
  description = "The ARN of the SNS topic for billing alerts"
  value       = aws_sns_topic.billing_alert.arn
}

output "cloudwatch_alarm_names" {
  description = "List of CloudWatch alarm names for total charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.estimated_charges : alarm.alarm_name]
}

output "service_alarm_names" {
  description = "List of CloudWatch alarm names for EC2 service charges"
  value       = [for alarm in aws_cloudwatch_metric_alarm.service_billing_alert : alarm.alarm_name]
}

output "sns_dlq_arn" {
  description = "The ARN of the SNS dead-letter queue"
  value       = aws_sqs_queue.sns_dlq.arn
}

output "email_subscription_count" {
  description = "Number of email subscriptions configured"
  value       = length(var.email_endpoints)
}

output "configuration_summary" {
  description = "Summary of billing alert configuration"
  value = {
    aws_region           = var.aws_region
    currency             = var.currency
    thresholds           = var.alert_thresholds
    email_count          = length(var.email_endpoints)
    environment          = var.environment_tag
    monitored_services   = ["AmazonEC2"]
  }
}
