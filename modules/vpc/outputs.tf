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

output "private_data_subnet_ids" {
  description = "IDs of private data subnets"
  value       = [aws_subnet.private_data_a.id, aws_subnet.private_data_b.id]
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this.id
}
