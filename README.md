# DevOps Project: AWS Infrastructure Automation, CI/CD Pipeline, and Monitoring

## Objective
 focusing on infrastructure automation, CI/CD pipelines, monitoring, and security within the AWS environment.

## Project Structure


devops-project/ ├── infrastructure/ │ ├── main.tf │ ├── variables.tf │ ├── outputs.tf ├── jenkins/ │ ├── main.tf │ ├── variables.tf │ ├── outputs.tf ├── ci-cd/ │ ├── Jenkinsfile ├── monitoring/ │ ├── cloudwatch.tf ├── README.md └── .gitignore


## Step-by-Step Guide

### 1. Automated Infrastructure Setup

#### Step 1: Install Terraform
- Download and install Terraform from the official website.

#### Step 2: Create Terraform Configuration Files
- Navigate to the `infrastructure` directory and create the following files:

**main.tf**
```hcl
provider "aws" {
  region = "ap-south-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
}

resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.web_sg.name]

  tags = {
    Name = "WebServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y nginx
              systemctl start nginx
              systemctl enable nginx
              EOF
}

variables.tf

variable "region" {
  description = "The AWS region to deploy resources in"
  default     = "ap-south-1"
}

outputs.tf

output "instance_id" {
  description = "The ID of the web server instance"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "The public IP of the web server instance"
  value       = aws_instance.web.public_ip
}

Step 3: Apply the Terraform Configuration
Initialize and apply the Terraform configuration:
terraform init
terraform apply

2. CI/CD Pipeline
Step 1: Install Jenkins
Install Jenkins on a separate EC2 instance using the following Terraform configuration in main.tf:
resource "aws_security_group" "jenkins_sg" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami           = "ami-0c55b159cbfafe1f0" # Amazon Linux 2 AMI
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public.id
  security_groups = [aws_security_group.jenkins_sg.name]

  tags = {
    Name = "JenkinsServer"
  }

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y java-1.8.0-openjdk
              wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
              rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              yum install -y jenkins
              systemctl start jenkins
              systemctl enable jenkins
              EOF
}

Step 2: Configure Jenkins
Access Jenkins at http://<jenkins_public_ip>:8080.
Follow the on-screen instructions to unlock Jenkins and install the suggested plugins.
Install necessary plugins: Git, Pipeline, AWS CLI, etc.
Step 3: Create a Jenkins Pipeline
Create a Jenkinsfile in the ci-cd directory:
pipeline {
    agent any

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://github.com/your-username/your-app.git'
            }
        }
        stage('Build') {
            steps {
                sh 'make build'
            }
        }
        stage('Test') {
            steps {
                sh 'make test'
            }
        }
        stage('Deploy') {
            steps {
                sshagent(['your-ssh-credentials-id']) {
                    sh 'scp -o StrictHostKeyChecking=no target/your-app.jar ec2-user@${env.WEB_SERVER_IP}:/path/to/deploy'
                    sh 'ssh -o StrictHostKeyChecking=no ec2-user@${env.WEB_SERVER_IP} "sudo systemctl restart your-app"'
                }
            }
        }
    }
}

Create a new Jenkins job:
Open Jenkins dashboard.
Click on New Item.
Enter a name for your job (e.g., My-Pipeline).
Select Pipeline and click OK.
In the Pipeline section, select Pipeline script from SCM.
Choose Git as the SCM.
Enter the repository URL (e.g., https://github.com/your-username/your-app.git).
Provide credentials if necessary.
Specify the branch (e.g., main).
Set the Script Path to ci-cd/Jenkinsfile.
Click Save.
3. Monitoring and Logging
Step 1: Set Up CloudWatch Monitoring
Create CloudWatch alarms for CPU, memory, and disk usage using the following Terraform configuration in cloudwatch.tf:
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "high_cpu_usage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  alarm_actions = [
    "arn:aws:sns:ap-south-1:123456789012:my-sns-topic"
  ]

  dimensions = {
    InstanceId = aws_instance.web.id
  }
}

Step 2: Apply the CloudWatch Configuration
Apply the CloudWatch configuration:
terraform apply -target=aws_cloudwatch_metric_alarm.high_cpu

Conclusion
This project demonstrates the setup of an AWS environment using Terraform, the creation of a CI/CD pipeline with Jenkins, and the implementation of monitoring using AWS CloudWatch. Follow the steps outlined above to replicate the setup and ensure all components are functioning as expected.