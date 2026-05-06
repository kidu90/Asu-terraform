output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.this.id
}

output "public_subnet_ids" {
  description = "IDs of public subnets"
  value       = [aws_subnet.public_a.id, aws_subnet.public_b.id]
}

output "private_app_subnet_ids" {
  description = "IDs of private app subnets"
  value       = [aws_subnet.private_app_a.id, aws_subnet.private_app_b.id]
}

output "private_app_route_table_ids" {
  description = "IDs of private app route tables"
  value       = [aws_route_table.private_app_a.id, aws_route_table.private_app_b.id]
}

output "private_data_subnet_ids" {
  description = "IDs of private data subnets"
  value       = [aws_subnet.private_data_a.id, aws_subnet.private_data_b.id]
}

output "private_data_route_table_ids" {
  description = "IDs of private data route tables"
  value       = [aws_route_table.private_data_a.id, aws_route_table.private_data_b.id]
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}

output "nat_gateway_ids" {
  description = "IDs of NAT gateways"
  value       = [aws_nat_gateway.nat_az_a.id, aws_nat_gateway.nat_az_b.id]
}

output "eip_public_ips" {
  description = "Public IPs of NAT gateway Elastic IPs"
  value       = [aws_eip.nat_az_a.public_ip, aws_eip.nat_az_b.public_ip]
}

output "vpn_connection_id" {
  description = "ID of the site-to-site VPN connection"
  value       = aws_vpn_connection.vpn.id
}

output "vpn_connection_tunnel1_address" {
  description = "Tunnel 1 outside IP address for the VPN connection"
  value       = aws_vpn_connection.vpn.tunnel1_address
}
