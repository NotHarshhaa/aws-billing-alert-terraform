# ==============================================================================
# Input Variables for AWS Billing Alert Module
# ==============================================================================

variable "aws_region" {
  description = "The AWS region for setting up billing resources. Note: AWS CloudWatch billing metric EstimatedCharges is exclusively published in us-east-1."
  type        = string
  default     = "us-east-1"

  validation {
    condition     = var.aws_region == "us-east-1"
    error_message = "AWS CloudWatch billing metric EstimatedCharges is ONLY available in the 'us-east-1' (US East N. Virginia) region. Please set aws_region to 'us-east-1'."
  }
}

variable "sns_topic_name" {
  description = "The name of the SNS topic for billing alerts"
  type        = string
  default     = "billing-alert"

  validation {
    condition     = can(regex("^[a-zA-Z0-9_-]{1,256}$", var.sns_topic_name))
    error_message = "sns_topic_name must be between 1 and 256 characters and can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "alert_thresholds" {
  description = "List of billing thresholds (in specified currency) to create total charge alarms for"
  type        = list(number)
  default     = [100, 150, 200]

  validation {
    condition     = length(var.alert_thresholds) > 0 && alltrue([for t in var.alert_thresholds : t > 0])
    error_message = "alert_thresholds must contain at least one positive number greater than 0."
  }
}

variable "services_to_monitor" {
  description = "List of AWS service names to monitor individually (e.g. ['AmazonEC2', 'AmazonRDS', 'AmazonS3']). Set to [] to disable per-service alarms."
  type        = list(string)
  default     = ["AmazonEC2"]
}

variable "service_alert_thresholds" {
  description = "Optional custom list of billing thresholds for per-service alarms. If null, alert_thresholds will be used."
  type        = list(number)
  default     = null

  validation {
    condition     = var.service_alert_thresholds == null || can([for t in var.service_alert_thresholds : t > 0])
    error_message = "If specified, service_alert_thresholds must only contain positive numbers greater than 0."
  }
}

variable "currency" {
  description = "Currency for the billing alert (e.g., USD, EUR, GBP, JPY)"
  type        = string
  default     = "USD"

  validation {
    condition     = can(regex("^[A-Z]{3}$", var.currency))
    error_message = "currency must be a valid 3-letter ISO currency code (e.g., 'USD', 'EUR', 'GBP')."
  }
}

variable "email_endpoints" {
  description = "List of email addresses to receive billing alerts"
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.email_endpoints : can(regex("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$", email))
    ])
    error_message = "All items in email_endpoints must be valid email addresses."
  }
}

variable "alarm_period" {
  description = "The evaluation period in seconds for CloudWatch billing alarms. AWS publishes billing metrics approximately every 6 hours (21600 seconds) or daily (86400 seconds)."
  type        = number
  default     = 21600

  validation {
    condition     = contains([21600, 43200, 86400], var.alarm_period)
    error_message = "alarm_period should be 21600 (6 hours), 43200 (12 hours), or 86400 (24 hours) to align with CloudWatch billing metric update intervals."
  }
}

variable "enable_ok_actions" {
  description = "Whether to send an SNS notification when an alarm transitions back to the OK state"
  type        = bool
  default     = true
}

variable "enable_sqs_endpoint" {
  description = "Whether to create and subscribe an SQS queue to the SNS topic for programmatic alert consumption"
  type        = bool
  default     = true
}

variable "enable_custom_billing_logs" {
  description = "Whether to create the /aws/billing CloudWatch log group and metric filter (enable only if you ingest custom billing logs into CloudWatch)"
  type        = bool
  default     = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed or customer-managed KMS key for SNS topic server-side encryption (e.g., 'alias/aws/sns' or KMS Key ARN). Set to null for default SSE."
  type        = string
  default     = null
}

variable "environment_tag" {
  description = "Tag to define the environment (e.g., Production, Staging, Development)"
  type        = string
  default     = "Production"
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "auto_confirm_subscription" {
  description = "Legacy variable kept for backward compatibility. Note: AWS SNS email subscriptions require the recipient to click the confirmation link in the verification email."
  type        = bool
  default     = false
}
