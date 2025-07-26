# modules/private_alb/outputs.tf

output "dns_name" {
  value = aws_lb.private.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.private_tg.arn
}
