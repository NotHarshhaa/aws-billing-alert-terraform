provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  common_tags = merge(
    {
      Environment = var.environment_tag
      ManagedBy   = "Terraform"
      Module      = "aws-billing-alert-terraform"
    },
    var.tags
  )

  service_thresholds = coalesce(var.service_alert_thresholds, var.alert_thresholds)

  # Flatten service and threshold pairs for per-service alarms
  service_alarms = flatten([
    for service in var.services_to_monitor : [
      for threshold in local.service_thresholds : {
        key       = "${service}-${threshold}"
        service   = service
        threshold = threshold
      }
    ]
  ])
}

# ==============================================================================
# Amazon SNS Topic & Policy
# ==============================================================================

resource "aws_sns_topic" "billing_alert" {
  name              = var.sns_topic_name
  kms_master_key_id = var.kms_master_key_id

  tags = merge(
    local.common_tags,
    {
      Purpose = "BillingAlerts"
    }
  )
}

# Secure SNS Topic Policy: Only allow CloudWatch alarms from this AWS account to publish
resource "aws_sns_topic_policy" "billing_alert_policy" {
  arn = aws_sns_topic.billing_alert.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchPublishBillingAlerts"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "sns:Publish"
        Resource = aws_sns_topic.billing_alert.arn
        Condition = {
          StringEquals = {
            "aws:SourceAccount" = data.aws_caller_identity.current.account_id
          }
          ArnLike = {
            "aws:SourceArn" = "arn:aws:cloudwatch:${var.aws_region}:${data.aws_caller_identity.current.account_id}:alarm:*"
          }
        }
      }
    ]
  })
}

# SNS Subscriptions for Email Endpoints
resource "aws_sns_topic_subscription" "email_alerts" {
  for_each  = toset(var.email_endpoints)
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = each.value
}

# ==============================================================================
# Optional SQS Queue (Alert Queue / Downstream Integration)
# ==============================================================================

resource "aws_sqs_queue" "sns_dlq" {
  count                      = var.enable_sqs_endpoint ? 1 : 0
  name                       = "${var.sns_topic_name}-dlq"
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 300
  sqs_managed_sse_enabled    = true

  tags = merge(
    local.common_tags,
    {
      Purpose = "BillingAlertsQueue"
    }
  )
}

# SQS Queue Policy: Allow only our SNS topic to send messages (prevents Confused Deputy)
resource "aws_sqs_queue_policy" "sns_dlq_policy" {
  count     = var.enable_sqs_endpoint ? 1 : 0
  queue_url = aws_sqs_queue.sns_dlq[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowBillingAlertSNSToPublish"
        Effect = "Allow"
        Principal = {
          Service = "sns.amazonaws.com"
        }
        Action   = "sqs:SendMessage"
        Resource = aws_sqs_queue.sns_dlq[0].arn
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.billing_alert.arn
          }
        }
      }
    ]
  })
}

# SQS Queue Subscription to SNS Topic
resource "aws_sns_topic_subscription" "sns_dlq_subscription" {
  count     = var.enable_sqs_endpoint ? 1 : 0
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.sns_dlq[0].arn

  depends_on = [aws_sqs_queue_policy.sns_dlq_policy]
}

# ==============================================================================
# Optional CloudWatch Log Group for Custom Billing Ingestion
# ==============================================================================

resource "aws_cloudwatch_log_group" "billing_logs" {
  count             = var.enable_custom_billing_logs ? 1 : 0
  name              = "/aws/billing"
  retention_in_days = 14

  tags = merge(
    local.common_tags,
    {
      Purpose = "BillingLogs"
    }
  )
}

resource "aws_cloudwatch_log_metric_filter" "billing_logs" {
  count          = var.enable_custom_billing_logs ? 1 : 0
  name           = "EstimatedChargesFilter"
  log_group_name = aws_cloudwatch_log_group.billing_logs[0].name
  pattern        = "{ $.EstimatedCharges > 0 }"

  metric_transformation {
    name      = "EstimatedChargesMetric"
    namespace = "CustomBilling"
    value     = "$.EstimatedCharges"
  }
}
