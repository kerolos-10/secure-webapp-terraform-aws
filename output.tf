output "public_alb_dns" {
  description = "DNS name of the public ALB"
  value       = module.public_alb.dns_name
}

output "proxy_public_ips" {
  value = module.proxy_ec2.public_ips
}


output "internal_alb_dns" {
  value = module.internal_alb.dns_name
}