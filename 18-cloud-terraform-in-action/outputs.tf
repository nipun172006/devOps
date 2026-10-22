output "vpc_id" {
  description = "ID of the lab VPC."
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "IDs of the two public subnets."
  value       = module.network.public_subnet_ids
}

output "web_instance_id" {
  description = "ID of the temporary web instance."
  value       = module.web.instance_id
}

output "web_public_ip" {
  description = "Public IPv4 address of the temporary web instance."
  value       = module.web.public_ip
}

output "web_url" {
  description = "HTTP URL for the intentionally public demonstration endpoint."
  value       = "http://${module.web.public_ip}"
}
