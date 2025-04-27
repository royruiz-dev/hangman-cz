# EC2 resource definitions (including security groups, instances, etc.)

# Define Security Groups (sg)
# Definining sg for instances to allow traffic flow
resource "aws_security_group" "instances" {
  name   = "instance-security-group"
  vpc_id = aws_vpc.main_vpc.id
}

# Allow traffic only from the ALB's security group
resource "aws_security_group_rule" "alb_to_ec2_http" {
  type                     = "ingress"
  from_port                = 8080
  to_port                  = 8080
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.instances.id
}

resource "aws_security_group_rule" "allow_ssh_inbound" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  # Commented out because GitHub runners use dynamic IPs, not my local IP.
  # cidr_blocks       = ["${var.my_ip}"]
  cidr_blocks       = ["0.0.0.0/0"] # Allows all ip addresses
  security_group_id = aws_security_group.instances.id
}

# Allow all outbound traffic
resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"] # Allows all ip addresses
  security_group_id = aws_security_group.instances.id
}

# Define Compute Resources
resource "aws_instance" "app_instances" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  key_name      = var.key_name

  count = 2 # Number of EC2 instances

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  subnet_id              = local.selected_subnet_ids[count.index] # Assign to each subnet
  vpc_security_group_ids = [aws_security_group.instances.id]

  tags = {
    name = "Instance-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.main_igw]
}
