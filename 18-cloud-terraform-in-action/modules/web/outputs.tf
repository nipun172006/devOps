output "instance_id" {
  description = "ID of the web instance."
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IPv4 address of the web instance."
  value       = aws_instance.web.public_ip
}

output "security_group_id" {
  description = "ID of the web security group."
  value       = aws_security_group.web.id
}

output "http_ingress_port" {
  description = "Port exposed by the intentional public HTTP rule."
  value       = one(aws_security_group.web.ingress).from_port
}

output "http_ingress_cidr" {
  description = "CIDR exposed by the intentional public HTTP rule."
  value       = one(aws_security_group.web.ingress).cidr_blocks
}

output "root_volume_encrypted" {
  description = "Whether the EC2 root volume is encrypted."
  value       = one(aws_instance.web.root_block_device).encrypted
}

output "imds_tokens_required" {
  description = "Whether IMDSv2 tokens are required."
  value       = aws_instance.web.metadata_options[0].http_tokens == "required"
}
