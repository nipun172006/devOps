variable "name" {
  description = "Name prefix for web resources."
  type        = string
}

variable "vpc_id" {
  description = "VPC where the web instance and security group are created."
  type        = string
}

variable "subnet_id" {
  description = "Public subnet for the web instance."
  type        = string
}

variable "ami_id" {
  description = "AMI used by the web instance."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
}

variable "web_message" {
  description = "Message served by the web workload."
  type        = string
}

variable "allowed_http_cidr" {
  description = "CIDR allowed to reach TCP port 80."
  type        = string
}

variable "tags" {
  description = "Tags applied to web resources."
  type        = map(string)
  default     = {}
}
