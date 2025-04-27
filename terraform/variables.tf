# Input variables for Terraform
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "key_name" {
  description = "Key used to SSH into EC2 instance"
  type        = string
  default     = "ansible-ec2-key"  # Name of key pair created/imported in AWS
}

variable "my_ip" {
  description = "IP address allowed to SSH into EC2 instance"
  type        = string
  default     = ""
}

variable "domain_name" {
  description = "Custom domain name"
  type        = string
  default     = ""
}