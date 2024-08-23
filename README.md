# 🚀 AWS Billing Alert Terraform Module

![AWS-billing](https://imgur.com/5DqRw6F.png)

Welcome to the **AWS Billing Alert Terraform module!** This module helps you set up automatic billing alerts for your AWS account. Once configured, you'll receive notifications when your AWS charges exceed specified amounts, helping you stay on top of your costs. 💰

## 🛠️ Prerequisites

> [!IMPORTANT]
> Before you begin, make sure you have the following:
>
> - 🧰 **Terraform (v1.5.0 or later)** installed on your local machine.
> - 🌐 **An AWS account** with appropriate permissions.
> - 🔑 **AWS CLI** configured with the necessary credentials.

## 🔍 Understanding the AWS Services

> [!NOTE]
>
> ### 🌟 AWS CloudWatch
>
> [AWS CloudWatch](https://aws.amazon.com/cloudwatch/) is a monitoring and observability service that collects and tracks metrics, collects and monitors log files, and sets alarms. This module uses CloudWatch to monitor your AWS billing and trigger an alarm when specified thresholds are exceeded.
>
> ### 📢 AWS SNS (Simple Notification Service)
>
> [AWS SNS](https://aws.amazon.com/sns/) is a fully managed messaging service. It allows you to send notifications to multiple subscribers. In this module, SNS is used to send billing alerts via email, SMS, or other supported channels when the CloudWatch alarm is triggered.
>
> ### 🧾 AWS Billing
>
> [AWS Billing](https://aws.amazon.com/aws-cost-management/aws-bill/) provides tools to manage your AWS costs and budget. This module automates the monitoring of your AWS billing, so you're notified before your bill goes beyond your expectations.

## 📦 Setup Instructions

### 1️⃣ Clone the Repository

Let's start by getting the code onto your machine.

1. Open your terminal or command prompt.
2. Navigate to the directory where you'd like to place the project:

   ```bash
   cd /path/to/your/directory
   ```

3. Clone the repository with the following command:

   ```bash
   git clone https://github.com/NotHarshhaa/aws-billing-alert-terraform.git
   ```

4. Move into the directory:

   ```bash
   cd aws-billing-alert-terraform
   ```

### 2️⃣ Install Terraform (If Not Already Installed)

If you don’t have Terraform installed yet, follow these steps for Amazon Linux:

1. **Install necessary packages**:

   ```bash
   sudo yum install -y yum-utils shadow-utils
   ```

2. **Add the HashiCorp repository**:

   ```bash
   sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
   ```

3. **Install Terraform**:

   ```bash
   sudo yum -y install terraform
   ```

4. **Verify the installation**:

   ```bash
   terraform --version
   ```

### 3️⃣ Initialize Terraform

Now, let's prepare Terraform to work with the module.

1. In the terminal, navigate to the directory where the repository was cloned.
2. Run the following command to initialize the module:

   ```bash
   terraform init
   ```

   This will download the necessary providers and set up your environment.

### 4️⃣ Configure Billing Alerts

By default, this module is set up to alert you when your AWS bill exceeds `$100` and `$120`. If you'd like to change these thresholds:

1. Open the `alert.tf` file in a text editor.
2. Modify the `thresholds` variable:

   ```hcl
   variable "thresholds" {
     description = "Billing thresholds for alerts"
     type        = list(number)
     default     = [100, 120]  # Update these values to your preference
   }
   ```

### 5️⃣ Apply the Terraform Configuration

Once everything is set up, apply the configuration to create the alerts:

```bash
terraform apply
```

You'll be presented with a plan that shows the resources Terraform will create. If everything looks good, type `yes` to proceed.

### 6️⃣ Verify Your Alerts

After Terraform finishes, check your AWS Management Console to verify that the CloudWatch alarms and SNS topics have been created. You'll start receiving alerts according to the thresholds you set.

## 🔧 Customization

You can customize the alert thresholds in the `alert.tf` file. By default, the alerts are set at `$100` and `$120`, but you can modify these values to fit your needs.

## 📬 Setting Up Notifications

Make sure to update the email address in `alert.tf` to receive notifications:

```hcl
resource "aws_sns_topic_subscription" "email_alert" {
  topic_arn = aws_sns_topic.billing_alert.arn
  protocol  = "email"
  endpoint  = "your-email@example.com" # Replace with your email
}
```

## 📝 Example Usage

Here’s a simple example to get started:

```hcl
module "billing_alert" {
  source  = "github.com/NotHarshhaa/aws-billing-alert-terraform"
  
  # Customize your billing threshold
  threshold_1 = 150
  threshold_2 = 200
}
```

> [!TIP]
>
> - Always keep your `.tfvars` files out of version control to avoid exposing sensitive information.
> - Use the `.terraform.lock.hcl` file to maintain consistent provider versions across your environments.

## 🎯 Usage

This module is designed to be flexible. You can adjust the billing thresholds, notification endpoints, and other settings to suit your needs. Just make sure to update the `alert.tf` file accordingly and reapply the configuration with `terraform apply`.

## 🙌 Feedback and Contributions

> [!TIP]
>
> _We'd love to hear your thoughts! Whether it's feedback, bug reports, or pull requests, feel free to get involved. Your contributions help make this module better for everyone._

## ⭐ Hit the Star

> [!IMPORTANT]
> _If you find this repository helpful for learning or in practice, **please hit the star button on GitHub.** ⭐ It helps others find this resource too!_

### 👤 Author

![banner](https://imgur.com/m1yp6yK.gif)

> [!TIP]
> **Join Our [Telegram Community](https://t.me/prodevopsguy) || [Follow me on GitHub](https://github.com/NotHarshhaa) for more DevOps content!**
