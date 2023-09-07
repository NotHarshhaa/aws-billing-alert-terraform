# AWS Billing Alert Terraform Module

![AWS-billing](https://imgur.com/5DqRw6F.png)

This repository contains a Terraform module that helps set up AWS billing alerts. Once configured, it will notify users when AWS charges exceed the specified amounts.

## Prerequisites
- Terraform installed on your local machine.
- An AWS account.
- AWS CLI configured with necessary credentials.

## Understanding the AWS Services

### AWS CloudWatch

[AWS CloudWatch](https://aws.amazon.com/cloudwatch/) is a monitoring and observability service. With CloudWatch, you can collect and access all your performance and operational data in form of logs and metrics from a single platform. This module uses CloudWatch to monitor your AWS billing and trigger an alarm when the specified thresholds are crossed.

### AWS SNS (Simple Notification Service)

[AWS SNS](https://aws.amazon.com/sns/) is a fully managed notification service. It allows you to send individual messages or to fan-out messages to large numbers of recipients. In the context of this module, SNS is used to send out notifications when the billing alarm in CloudWatch is triggered.

### AWS Billing

[AWS Billing](https://aws.amazon.com/aws-cost-management/aws-bill/) provides you with tools and features to pay for what you use, manage your costs, and budget your AWS costs. AWS charges can accumulate quickly depending on the services and the usage, hence monitoring the billing is crucial. This module helps in automating the monitoring process and alerts you before your bill goes beyond your expectations.



## Setup
1. **Clone the Repository**

   ### Clone Repository

You can clone this repository to your local machine using the following steps:

1. Open your terminal or command prompt.

2. Navigate to the directory where you want to clone the repository:

   ```
   cd /path/to/your/directory
   ```
- Replace /path/to/your/directory with the actual path to your desired directory.

- Clone the repository by running the following command:



```
git clone https://github.com/NotHarshhaa/aws-billing-alert-terraform.git
```
This will create a copy of the repository on your local machine.

Change your working directory to the cloned repository:

```
cd aws-billing-alert-terraform
```
Now you have successfully cloned the repository to your local machine and can start working with it.

**Note:** Ensure that you have Git installed on your machine before running the git clone command.

- Replace `/path/to/your/directory`

# Terraform Installation Guide for Amazon Linux

This guide will walk you through the installation of Terraform on an Amazon Linux system using `yum`. Terraform is an infrastructure as code tool that allows you to define and provision infrastructure resources in a declarative configuration file.

## Prerequisites

Before you begin, make sure you have the following prerequisites:
- An Amazon Linux system.
- `sudo` or root access to your server.

## Installation Steps

Follow these steps to install Terraform on your Amazon Linux system:

```
# Install necessary packages
sudo yum install -y yum-utils shadow-utils

# Add HashiCorp repository for Amazon Linux
sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo

# Install Terraform
sudo yum -y install terraform

```

After the installation is complete, you can verify the installation by checking the Terraform version:

```
terraform --version

```


2. **Initialize Terraform**

   Navigate to the directory where you've cloned the repository and run:

```
terraform init
```

3. **Apply the Terraform Configuration**

After initializing, apply the Terraform configuration:

```
terraform apply 
```

Review the plan, and if everything looks good, proceed by typing `yes`.

## Usage
Modify the Terraform configuration as needed to fit your requirements. **By default, alerts are set at $100 and $120, but you can adjust these values in the main Terraform file.**

## Feedback and Contributions
Feedback, bug reports, and pull requests are welcomed. Feel free to raise an issue or submit a pull request.


# Hit the Star! ⭐
***If you are planning to use this repo for learning, please hit the star. Thanks!***

#### Author by [Harshhaa Reddy](https://github.com/NotHarshhaa)
