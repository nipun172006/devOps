provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Module      = "18-cloud-terraform-in-action"
      Project     = var.project_name
      Environment = var.environment
      Owner       = var.owner
    }
  }
}
