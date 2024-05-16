# Private Subnet
resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.private_subnets_cidr)
  cidr_block              = element(var.private_subnets_cidr, count.index)
  availability_zone       = element(local.az_names, count.index)
  map_public_ip_on_launch = false

  tags = {
    Name        = "${local.environment}-${element(local.az_names, count.index)}-private-subnet"
    Environment = "${local.environment}"
  }
}