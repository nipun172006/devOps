data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023*-x86_64"]
  }

  filter {
    name   = "state"
    values = ["available"]
  }
}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Name = local.name_prefix
  }
  selected_ami_id = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux.id
}

module "network" {
  source = "./modules/network"

  name               = local.name_prefix
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  public_subnet_cidrs = [
    cidrsubnet(var.vpc_cidr, 8, 10),
    cidrsubnet(var.vpc_cidr, 8, 11),
  ]
  tags = local.common_tags
}

module "web" {
  source = "./modules/web"

  name              = local.name_prefix
  vpc_id            = module.network.vpc_id
  subnet_id         = module.network.public_subnet_ids[0]
  ami_id            = local.selected_ami_id
  instance_type     = var.instance_type
  web_message       = var.web_message
  allowed_http_cidr = var.allowed_http_cidr
  tags              = local.common_tags
}
