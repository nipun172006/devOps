variable "aws_region" {
  description = "AWS region where the temporary lab infrastructure is created."
  type        = string
  default     = "ap-south-1"

  validation {
    condition     = can(regex("^[a-z]{2}(-gov)?-[a-z]+-[0-9]+$", var.aws_region))
    error_message = "aws_region must be a valid AWS region name."
  }
}

variable "project_name" {
  description = "Lowercase project name used in resource names and tags."
  type        = string
  default     = "devops-module18"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,30}$", var.project_name))
    error_message = "project_name must be 3-31 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Environment represented by this temporary infrastructure."
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "test", "staging", "prod"], var.environment)
    error_message = "environment must be dev, test, staging, or prod."
  }
}

variable "owner" {
  description = "Owner tag used for accountability."
  type        = string
  default     = "devops-student"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty."
  }
}

variable "vpc_cidr" {
  description = "CIDR range for the lab VPC."
  type        = string
  default     = "10.18.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block."
  }
}

variable "availability_zones" {
  description = "Two availability zones used for the public subnets."
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]

  validation {
    condition     = length(var.availability_zones) == 2 && length(distinct(var.availability_zones)) == 2
    error_message = "availability_zones must contain two different zones."
  }
}

variable "instance_type" {
  description = "Small EC2 instance type used for the temporary web workload."
  type        = string
  default     = "t3.micro"

  validation {
    condition     = contains(["t3.micro", "t4g.nano"], var.instance_type)
    error_message = "instance_type must be t3.micro or t4g.nano for this low-cost lab."
  }
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach the intentionally public HTTP demonstration endpoint."
  type        = string
  default     = "0.0.0.0/0"

  validation {
    condition     = can(cidrhost(var.allowed_http_cidr, 0))
    error_message = "allowed_http_cidr must be a valid CIDR block."
  }
}

variable "web_message" {
  description = "Message returned by the temporary HTTP service."
  type        = string
  default     = "Module 18 Terraform web server"

  validation {
    condition     = length(trimspace(var.web_message)) > 0 && length(var.web_message) <= 120
    error_message = "web_message must contain 1-120 non-empty characters."
  }
}

variable "ami_id" {
  description = "Optional AMI override; leave empty to use the latest Amazon Linux 2023 x86_64 AMI."
  type        = string
  default     = ""
}
