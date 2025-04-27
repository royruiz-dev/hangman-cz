# Terraform output values
output "instance_ips" {
  description = "List of IP addresses of the instances"
  value = aws_instance.app_instances[*].public_ip
}

output "alb_dns_name" {
  description = "DNS name of the alb to access the app"
  value = aws_lb.load_balancer.dns_name
}

output "route53_name_servers" {
  description = "List of Route53 name servers"
  value       = aws_route53_zone.primary[*].name_servers
}

output "domain_name_url" {
  description = "URL to access the app"
  value = local.domain_provided ? "http://${var.domain_name}" : null
}