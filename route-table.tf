# Route table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.environment}-private-route-table"
    Environment = "${local.environment}"
  }
}

# Route table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name        = "${local.environment}-public-route-table"
    Environment = "${local.environment}"
  }
}

# Route for Internet Gateway
resource "aws_route" "public_internet_gateway" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.ig.id
}

# Route for NAT Gateway
resource "aws_route" "private_internet_gateway" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_nat_gateway.nat.id
}