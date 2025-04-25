# Terraform output values
output "instance_ips" {
  value = aws_instance.app_instances[*].public_ip
}
