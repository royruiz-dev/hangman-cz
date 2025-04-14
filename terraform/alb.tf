# ALB resource + ALB security group + Listener Rule

# Definining sg for load balancer to allow traffic flow
resource "aws_security_group" "alb" {
  name   = "alb-security-group"
  vpc_id = aws_vpc.main_vpc.id
}

# Allowing inbound traffic and attaching rule to sg for load balancer
resource "aws_security_group_rule" "allow_alb_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Allows all ip addresses
  security_group_id = aws_security_group.alb.id
}

# Allowing outbound traffic and attaching rule to sg for load balancer
resource "aws_security_group_rule" "allow_alb_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] # Allows all ip addresses
  security_group_id = aws_security_group.alb.id
}

# Define Load Balancer (lb) and configuration
# Define load balancer, which subnet to provision into and which sg to use
resource "aws_lb" "load_balancer" {
  name               = "app-lb"
  internal           = false # public-facing lb for app
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = local.selected_subnet_ids # List of subnets

  # enable_deletion_protection = true
}

# Define the lb target group (alb forwards to EC2:8080)
# Define where to send the traffic by defining a target group
resource "aws_lb_target_group" "app_target_group" {
  name     = "app-lb-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.main_vpc.id

  health_check {
    path                = "/" # default for HTTP/HTTPS health checks
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_target_group_attachment" "instance_attachments" {
  for_each = {
    for k, v in aws_instance.app_instances : k => v.id
  }

  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id        = each.value
  port             = 8080
}

# Define the load balancer (lb) listener
# Set up lb listener configuration to have inbound traffic coming from the web
resource "aws_lb_listener" "app_lb_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = "80"
  protocol          = "HTTP"

  # Return a simple 404 page by default
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = "404"
    }
  }
}

# Define the load balancer (lb) listener rule
resource "aws_lb_listener_rule" "app_lb_listener_rule" {
  listener_arn = aws_lb_listener.app_lb_listener.arn # Listener the rule belongs to
  priority     = 100                                 # Rules processed in ascending order

  condition {
    path_pattern {
      values = ["/", "/static/*", "/nouns"] # Handles root, static files, and API endpoint
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}
