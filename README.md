# 🚀 AWS Billing Alert Terraform Module  

![AWS-billing](https://imgur.com/wtaBi16.png)  

Welcome to the **AWS Billing Alert Terraform module!** This module helps you set up automatic billing alerts for your AWS account. Once configured, you'll receive notifications when your AWS charges exceed specified amounts, helping you stay on top of your costs. 💰  

---

## 🛠️ Prerequisites  

> [!IMPORTANT]
> **Before you begin, make sure you have the following:**  
>
> - 🧰 **Terraform (v1.5.0 or later)** installed on your local machine.  
> - 🌐 **An AWS account** with appropriate permissions.  
> - 🔑 **AWS CLI** configured with the necessary credentials.  

---

## 🔍 Understanding the AWS Services  

### 🌟 AWS CloudWatch  

[AWS CloudWatch](https://aws.amazon.com/cloudwatch/) is a monitoring and observability service that collects and tracks metrics, collects and monitors log files, and sets alarms. This module uses CloudWatch to monitor your AWS billing and trigger an alarm when specified thresholds are exceeded.  

### 📢 AWS SNS (Simple Notification Service)  

[AWS SNS](https://aws.amazon.com/sns/) is a fully managed messaging service. It allows you to send notifications to multiple subscribers. In this module, SNS is used to send billing alerts via email, SMS, or other supported channels when the CloudWatch alarm is triggered.  

### 🧾 AWS Billing  

[AWS Billing](https://aws.amazon.com/aws-cost-management/aws-bill/) provides tools to manage your AWS costs and budget. This module automates the monitoring of your AWS billing, so you're notified before your bill goes beyond your expectations.  

---

## 🚀 Latest Features & Security Improvements [2025]

✅ **Enhanced Security** – Added proper SNS and SQS policies for secure communication  
✅ **Fixed DLQ Integration** – Dead-letter queue now properly handles failed notifications  
✅ **Resource Dependencies** – Proper dependency management for reliable deployment  
✅ **Multiple Email Alerts** – Supports multiple recipients by allowing a list of emails  
✅ **Per-Service Billing Alerts** – Monitors spending on individual AWS services like EC2  
✅ **Enhanced CloudWatch Filters** – Improved billing log monitoring for better cost visibility  
✅ **OK Actions** – Sends recovery notifications when charges return to normal  
✅ **Better Code Organization** – Separated outputs and versions for maintainability  
✅ **Configuration Summary** – Enhanced outputs for better monitoring and debugging  

---

## 📦 Setup Instructions  

### 1️⃣ Clone the Repository  

1. Open your terminal or command prompt.  
2. Navigate to the directory where you'd like to place the project:  

   ```bash  
   cd /path/to/your/directory  
   ```  

3. Clone the repository:  

   ```bash  
   git clone https://github.com/NotHarshhaa/aws-billing-alert-terraform.git  
   ```  

4. Move into the directory:  

   ```bash  
   cd aws-billing-alert-terraform  
   ```  

---

### 2️⃣ Install Terraform  

Follow the steps in your system documentation to install **Terraform** or use the quick instructions for Amazon Linux:  

```bash  
sudo yum install -y yum-utils shadow-utils  
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo  
sudo yum -y install terraform  
terraform --version  
```  

---

### 3️⃣ Initialize Terraform  

Prepare Terraform for use:  

```bash  
terraform init  
```  

---

### 4️⃣ Configure and Apply Changes  

#### Update Configuration Variables:  

Configure your billing alerts using the provided `terraform.tfvars.example` file:  

```hcl  
# Copy terraform.tfvars.example to terraform.tfvars and customize
aws_region            = "us-east-1"  
alert_thresholds      = [100, 150, 200]  
currency              = "USD"  
email_endpoints       = ["your-email@example.com", "team@example.com"]  
environment_tag       = "Production"  
auto_confirm_subscription = false  
sns_topic_name        = "billing-alert"  
```  

**Key Features:**  
- 🔒 **Secure by Default** – Proper IAM policies and access controls  
- 📧 **Multiple Recipients** – Send alerts to multiple email addresses  
- 🔄 **Reliable Delivery** – DLQ handles failed notifications automatically  
- 📊 **Service Monitoring** – Separate alerts for total and EC2-specific charges  
- ✅ **Recovery Notifications** – Get alerts when charges return to normal  

#### Apply the Configuration:  

```bash  
terraform apply  
```  

---

## 📝 Example Usage  

Here's an example configuration:  

```hcl  
module "billing_alert" {  
  source                     = "github.com/NotHarshhaa/aws-billing-alert-terraform"  
  aws_region                 = "us-west-2"  
  alert_thresholds           = [100, 150, 200]  
  email_endpoints            = ["my-email@example.com", "finance@example.com"]  
  auto_confirm_subscription  = false  
  currency                   = "USD"  
  environment_tag            = "Production"  
  sns_topic_name             = "billing-alert"  
}  
```  

### 📊 Module Outputs  

After deployment, you'll get these useful outputs:  

```hcl  
# SNS topic for monitoring  
output "sns_topic_arn"  

# List of all alarm names  
output "cloudwatch_alarm_names"  
output "service_alarm_names"  

# DLQ for troubleshooting  
output "sns_dlq_arn"  

# Configuration summary  
output "configuration_summary"  
```  

---

## 🎯 Usage  

This module is designed for **simplicity and reliability**:  

1. **Quick Setup** – Copy `terraform.tfvars.example` to `terraform.tfvars`  
2. **Configure Emails** – Add your email addresses to `email_endpoints`  
3. **Set Thresholds** – Adjust `alert_thresholds` based on your budget  
4. **Deploy** – Run `terraform apply`  
5. **Monitor** – Receive alerts when charges exceed your thresholds  

### 🔧 Advanced Configuration  

The module supports these customizations:  
- **Multiple thresholds** – Get alerts at different spending levels  
- **Service-specific monitoring** – EC2 service charges tracked separately  
- **Custom regions and currencies** – Deploy anywhere with local currency  
- **Environment tagging** – Organize resources by environment  

### 🛡️ Security Features  

- **Least Privilege Access** – Only necessary permissions granted  
- **Secure Communication** – Proper SNS and SQS policies  
- **Resource Isolation** – Clear separation of concerns  
- **No Hardcoded Secrets** – All configuration via variables  

---

## � Customization

### Billing Thresholds

Modify the `alert_thresholds` in your `terraform.tfvars` file to configure additional thresholds:

```hcl
alert_thresholds = [100, 150, 200, 250]
```

### Email Subscription Auto-Confirmation

For testing purposes, you can enable automatic email confirmation by setting:

```hcl
auto_confirm_subscription = true
```

> [!IMPORTANT]
> **Use this option only in test environments with proper permissions.**

### Supported Variables

| Variable | Description | Default | Required |
|----------|-------------|---------|----------|
| `aws_region` | AWS region for deployment | `us-east-1` | No |
| `alert_thresholds` | Billing thresholds in USD | `[100, 120]` | No |
| `email_endpoints` | Email addresses for alerts | `['your-email@example.com']` | Yes |
| `currency` | Billing currency | `USD` | No |
| `environment_tag` | Environment tag for resources | `Production` | No |
| `auto_confirm_subscription` | Auto-confirm email subs | `false` | No |
| `sns_topic_name` | SNS topic name | `billing-alert` | No |

---

## �🙌 Feedback and Contributions

> [!TIP]  
> _We'd love to hear your thoughts! Whether it's feedback, bug reports, or pull requests, feel free to get involved. Your contributions help make this module better for everyone._

## ⭐ Hit the Star  

> [!IMPORTANT]  
> _If you find this repository helpful for learning or in practice, **please hit the star button on GitHub.** ⭐ It helps others find this resource too!_

### 👤 Author  

![banner](https://imgur.com/2j7GSPs.png)

> [!TIP]  
> **Join Our [Telegram Community](https://t.me/prodevopsguy) || [Follow me on GitHub](https://github.com/NotHarshhaa) for more DevOps content!**
