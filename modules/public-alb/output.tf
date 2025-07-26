

# modules/public_alb/outputs.tf

output "dns_name" {
  value = aws_lb.public.dns_name
}

output "arn" {
  value = aws_lb.public.arn
}

output "target_group_arn" {
  value = aws_lb_target_group.public_tg.arn
}