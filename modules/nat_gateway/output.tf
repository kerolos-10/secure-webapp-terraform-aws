output "nat_gateway_id" {
  description = "The ID of the NAT Gateway"
  value       = aws_nat_gateway.nat_gateway.id
}

output "nat_gateway_eip" {
  description = "The Elastic IP associated with the NAT Gateway"
  value       = aws_eip.nat_eip.public_ip
}
