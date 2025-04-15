# Define DNS via Route 53 to access via domain name and point to load balancer
# Provisions domain as a zone in Route53
resource "aws_route53_zone" "primary" {
  name = "royruiz.com"
}

# An alias record for the specified Route53 zone
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "royruiz.com"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer.dns_name
    zone_id                = aws_lb.load_balancer.zone_id
    evaluate_target_health = true
  }
}
