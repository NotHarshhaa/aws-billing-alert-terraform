provider "aws" {
  region = "us-east-1" # AWS Billing metric is only available in us-east-1
}

resource "aws_sns_topic" "billing_alert" {
  name = "billing-alert"
}

resource "aws_cloudwatch_metric_alarm" "estimated_charges_100" {
  alarm_name          = "estimated-charges-100"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours in seconds
  statistic           = "Maximum"
  threshold           = "100"
  alarm_description   = "Alarm when AWS charges go above $100"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = "USD"
  }
}

resource "aws_cloudwatch_metric_alarm" "estimated_charges_120" {
  alarm_name          = "estimated-charges-120"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "EstimatedCharges"
  namespace           = "AWS/Billing"
  period              = "86400" # 24 hours in seconds
  statistic           = "Maximum"
  threshold           = "120"
  alarm_description   = "Alarm when AWS charges go above $120"
  alarm_actions       = [aws_sns_topic.billing_alert.arn]
  treat_missing_data  = "notBreaching"
  dimensions = {
    Currency = "USD"
  }
}

# Add your email subscription to the SNS topic.
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = "your-email@example.com" # Replace with your email
}

