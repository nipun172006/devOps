variable "aws_region" {
  description = "AWS region where the lab bucket is created."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Lowercase project name used in the generated bucket prefix."
  type        = string
  default     = "nipun-terraform-lab"

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{2,30}$", var.project_name))
    error_message = "project_name must be 3-31 lowercase letters, numbers, or hyphens."
  }
}

variable "environment" {
  description = "Deployment environment represented by the infrastructure."
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
  default     = "nipun172006"

  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty."
  }
}
