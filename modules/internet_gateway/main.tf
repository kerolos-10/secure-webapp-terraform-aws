resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name        = var.name
    Environment = var.environment
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name        = var.route_table_name
    Environment = var.environment
  }
}

# Associate the Route Table with Private Subnet
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.public_subnet_ids)
  subnet_id      = element(var.public_subnet_ids, count.index)
  route_table_id = aws_route_table.public_rt.id
}
