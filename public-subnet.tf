# Public subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.vpc.id
  count                   = length(var.public_subnets_cidr)
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(local.az_names, count.index)
  map_public_ip_on_launch = true

  tags = {
    Name        = "${local.environment}-${element(local.az_names, count.index)}-public-subnet"
    Environment = "${local.environment}"
  }
}



