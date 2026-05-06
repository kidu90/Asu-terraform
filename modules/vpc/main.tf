resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  tags                 = var.tags
}

# Public subnets
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true
  tags                    = var.tags
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-south-1b"
  map_public_ip_on_launch = true
  tags                    = var.tags
}

# Private app subnets
resource "aws_subnet" "private_app_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-south-1a"
  tags              = var.tags
}

resource "aws_subnet" "private_app_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-south-1b"
  tags              = var.tags
}

# Private data subnets
resource "aws_subnet" "private_data_a" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.21.0/24"
  availability_zone = "ap-south-1a"
  tags              = var.tags
}

resource "aws_subnet" "private_data_b" {
  vpc_id            = aws_vpc.this.id
  cidr_block        = "10.0.22.0/24"
  availability_zone = "ap-south-1b"
  tags              = var.tags
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

# Public route table and route to IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this.id
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

# Private app route tables
resource "aws_route_table" "private_app_a" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table" "private_app_b" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table_association" "private_app_a_assoc" {
  subnet_id      = aws_subnet.private_app_a.id
  route_table_id = aws_route_table.private_app_a.id
}

resource "aws_route_table_association" "private_app_b_assoc" {
  subnet_id      = aws_subnet.private_app_b.id
  route_table_id = aws_route_table.private_app_b.id
}

# Private data route tables
resource "aws_route_table" "private_data_a" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table" "private_data_b" {
  vpc_id = aws_vpc.this.id
  tags   = var.tags
}

resource "aws_route_table_association" "private_data_a_assoc" {
  subnet_id      = aws_subnet.private_data_a.id
  route_table_id = aws_route_table.private_data_a.id
}

resource "aws_route_table_association" "private_data_b_assoc" {
  subnet_id      = aws_subnet.private_data_b.id
  route_table_id = aws_route_table.private_data_b.id
}
