# Elastic IP for the NAT Gateway
resource "aws_eip" "nat_eip" {
  tags = {
    Name = "NAT-Gateway-EIP"
    Environment = var.environment
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = var.public_subnet_id

  tags = {
    Name = "NAT-Gateway"
    Environment = var.environment
  }
}

# Route Table for Private Subnet
resource "aws_route_table" "private_route_table" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private-Route-Table"
    Environment = var.environment
  }
}

# Associate the Route Table with Private Subnet
resource "aws_route_table_association" "private_route_table_association" {
  count          = length(var.private_subnet_ids)
  subnet_id      = element(var.private_subnet_ids, count.index)
  route_table_id = aws_route_table.private_route_table.id
}