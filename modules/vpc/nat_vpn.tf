resource "aws_eip" "nat_az_a" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-nat-eip-az-a"
    }
  )
}

resource "aws_eip" "nat_az_b" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-nat-eip-az-b"
    }
  )
}

resource "aws_nat_gateway" "nat_az_a" {
  allocation_id     = aws_eip.nat_az_a.id
  subnet_id         = aws_subnet.public_a.id
  connectivity_type = "public"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-nat-az-a"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "nat_az_b" {
  allocation_id     = aws_eip.nat_az_b.id
  subnet_id         = aws_subnet.public_b.id
  connectivity_type = "public"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-nat-az-b"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_app_a_default" {
  route_table_id         = aws_route_table.private_app_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az_a.id
}

resource "aws_route" "private_app_b_default" {
  route_table_id         = aws_route_table.private_app_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az_b.id
}

resource "aws_route" "private_data_a_default" {
  route_table_id         = aws_route_table.private_data_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az_a.id
}

resource "aws_route" "private_data_b_default" {
  route_table_id         = aws_route_table.private_data_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_az_b.id
}

resource "aws_customer_gateway" "cgw" {
  bgp_asn    = 65000
  ip_address = var.on_prem_ip
  type       = "ipsec.1"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-cgw"
    }
  )
}

resource "aws_vpn_gateway" "vgw" {
  vpc_id            = aws_vpc.this.id
  availability_zone = "ap-south-1a"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-vgw"
    }
  )
}

resource "aws_vpn_gateway_attachment" "vgw_attachment" {
  vpc_id         = aws_vpc.this.id
  vpn_gateway_id = aws_vpn_gateway.vgw.id
}

resource "aws_vpn_connection" "vpn" {
  customer_gateway_id = aws_customer_gateway.cgw.id
  vpn_gateway_id      = aws_vpn_gateway.vgw.id
  type                = "ipsec.1"
  static_routes_only  = true

  local_ipv4_network_cidr  = "0.0.0.0/0"
  remote_ipv4_network_cidr = "192.168.0.0/16"

  tags = merge(
    var.tags,
    {
      Name = "asu-${var.environment}-vpn"
    }
  )
}
