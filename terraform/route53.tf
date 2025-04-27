# Define DNS via Route 53 to access via domain name and point to load balancer
# Provisions domain as a Route53 zone
locals {
  domain_provided = var.domain_name != ""
}

resource "aws_route53_zone" "primary" {
  count = var.domain_name != "" ? 1 : 0
  name = var.domain_name
}

# root A record for the specified Route53 zone
resource "aws_route53_record" "root" {
  count = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.primary[0].zone_id
  name = var.domain_name
  type = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}

# www A record for the specified Route53 zone
resource "aws_route53_record" "www" {
  count = var.domain_name != "" ? 1 : 0
  zone_id = aws_route53_zone.primary[0].zone_id
  name    = "www.${var.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
