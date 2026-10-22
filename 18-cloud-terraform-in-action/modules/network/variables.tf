variable "name" {
  description = "Name prefix for network resources."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR range for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Availability zones for the public subnets."
  type        = list(string)
}

variable "public_subnet_cidrs" {
  description = "CIDR ranges for the public subnets."
  type        = list(string)

  validation {
    condition     = length(var.public_subnet_cidrs) == 2
    error_message = "Exactly two public subnet CIDRs are required."
  }
}

variable "tags" {
  description = "Tags applied to network resources."
  type        = map(string)
  default     = {}
}
