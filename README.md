# AWS Billing Alert Terraform

Terraform configuration to create AWS billing alarms, SNS notifications, and a dashboard for cost visibility.

## What this creates

- SNS topic for billing notifications.
- Email subscriptions for one or many recipients.
- SQS dead-letter queue (DLQ) for SNS deliveries, including queue policy.
- CloudWatch alarms for total estimated charges at multiple thresholds.
- CloudWatch alarms for service-specific estimated charges (EC2 by default).
- CloudWatch dashboard with estimated charges metric.

## Requirements

- Terraform `>= 1.5.0`
- AWS provider `>= 5.0`
- AWS account with billing metric access (billing metrics are in `us-east-1`)

## Usage

1. Initialize Terraform:

```bash
terraform init
```

2. Create a `terraform.tfvars` file (example):

```hcl
aws_region                 = "us-east-1"
alert_thresholds           = [100, 150, 200]
currency                   = "USD"
email_endpoints            = ["your-email@example.com", "team@example.com"]
auto_confirm_subscription  = false
environment_tag            = "Production"
```

3. Review and apply:

```bash
terraform plan
terraform apply
```

## Inputs

- `aws_region` – AWS region for resources.
- `sns_topic_name` – SNS topic name.
- `alert_thresholds` – Positive billing thresholds.
- `email_endpoints` – List of email addresses.
- `currency` – Billing currency dimension.
- `environment_tag` – Resource tag value.
- `auto_confirm_subscription` – Whether to auto-confirm SNS subscriptions where supported.

## Outputs

- `sns_topic_arn`
- `cloudwatch_alarm_names`
- `sns_dlq_arn`
- `billing_dashboard_name`

## Notes

- Billing metrics are global and emitted in `us-east-1`.
- Email SNS subscriptions generally require recipient confirmation.
