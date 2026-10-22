mock_provider "aws" {}

run "secure_network_and_web_plan" {
  command = plan

  variables {
    ami_id = "ami-0123456789abcdef0"
  }

  assert {
    condition     = module.network.dns_hostnames_enabled && module.network.dns_support_enabled
    error_message = "The VPC must enable DNS hostnames and DNS support."
  }

  assert {
    condition     = alltrue(module.network.public_subnets_assign_public_ip)
    error_message = "Both public subnets must assign public IPv4 addresses."
  }

  assert {
    condition     = module.web.http_ingress_port == 80
    error_message = "The lab should expose the intentional HTTP demonstration port."
  }

  assert {
    condition     = module.web.root_volume_encrypted
    error_message = "The EC2 root volume must be encrypted."
  }

  assert {
    condition     = module.web.imds_tokens_required
    error_message = "EC2 IMDSv2 must be required."
  }
}
