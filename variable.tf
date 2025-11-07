variable "aws_access_key" {
  description = "The aws access key"
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
}
variable "aws_secret_key" {
  description = "The aws secret key"
  type        = string
  sensitive   = true # Mark as sensitive to prevent logging
}

variable "region" {
  default = "us-east-1"
}


variable "main-vpc" {
  default = "mainvpc"
}

variable "vpc-cidr" {
  default = "10.0.0.0/16"
}

variable "count-subnet" {
  default = 2
}

variable "main_vpc_sg" {
  default = "main-vpc-sg"
}

variable "key_name" {
  description = "The name for the AWS key pair"
  type        = string
  default     = "terraform-generated-key"
}

variable "main_vpc_ec2" {
  default = "main-vpc-ec2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to SSH into instances (default wide open - change for production)"
  type        = string
  default     = "0.0.0.0/0"
}

variable "ami" {
  description = "The AMI ID to use for launching the EC2 instance"
  type        = string
  default     = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI in us-east-1
}

variable "subnet_id" {
  description = "The subnet ID where the EC2 instance will be created"
  type        = string
  default     = "aws_subnet.public-subnet[0].id"
}
# VPC or project name prefix for tagging
variable "main_vpc" {
  description = "Main VPC or project name prefix used for tagging AWS resources"
  type        = string
  default     = "main-vpc"
}

# Environment tag (optional, e.g., dev, staging, prod)
variable "environment" {
  description = "Deployment environment tag (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}
