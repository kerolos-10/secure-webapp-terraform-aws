output "instance_ids" {
  value = [for inst in aws_instance.proxy : inst.id]
}
output "public_ips" {
  value = aws_instance.proxy[*].public_ip
}
