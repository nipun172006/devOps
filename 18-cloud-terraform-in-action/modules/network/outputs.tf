output "vpc_id" {
  description = "ID of the VPC."
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets in availability-zone order."
  value       = [for az in var.availability_zones : aws_subnet.public[az].id]
}

output "internet_gateway_id" {
  description = "ID of the internet gateway."
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table."
  value       = aws_route_table.public.id
}

output "dns_hostnames_enabled" {
  description = "Whether DNS hostnames are enabled for the VPC."
  value       = aws_vpc.this.enable_dns_hostnames
}

output "dns_support_enabled" {
  description = "Whether DNS support is enabled for the VPC."
  value       = aws_vpc.this.enable_dns_support
}

output "public_subnets_assign_public_ip" {
  description = "Whether each public subnet assigns public IPv4 addresses."
  value       = [for az in var.availability_zones : aws_subnet.public[az].map_public_ip_on_launch]
}
