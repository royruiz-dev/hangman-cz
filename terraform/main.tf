# When no remote backend is specified, it defaults to local
terraform {
  # ###########################################################
  # ## AFTER RUNNING TERRAFORM APPLY (WITH LOCAL BACKEND)
  # ## UNCOMMENT THIS CODE AND RERUN TERRAFORM INIT
  # ## TO SWITCH FROM LOCAL TO REMOTE AWS BACKEND
  # ###########################################################
  backend "s3" {
    bucket         = "royente-tf-state"
    region         = "eu-central-1"
    key            = "hangman-deploy/terraform.tfstate"
    dynamodb_table = "terraform-state-locking"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0"
    }
  }
}

# Configure the AWS provier
provider "aws" {
  region = var.aws_region
}

module "backend_resources" {
  source = "./backend"
}
