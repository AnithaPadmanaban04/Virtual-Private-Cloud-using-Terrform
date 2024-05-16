# Elastic-IP (eip) for NAT
resource "aws_eip" "nat_eip" {
  domain        = "vpc"
  depends_on    = [aws_internet_gateway.ig]
}

# NAT Gateway
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  tags = {
    Name        = "nat-gateway-${local.environment}"
    Environment = "${local.environment}"
  }
  depends_on    = [aws_eip.nat_eip]
}

