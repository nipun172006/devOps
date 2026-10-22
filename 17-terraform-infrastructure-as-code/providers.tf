provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
      Module    = "17-terraform-infrastructure-as-code"
    }
  }
}
