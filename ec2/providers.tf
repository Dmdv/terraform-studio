terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

#  backend "s3" {
#    bucket         = "learning.terraform.tf-state.root.ap-east-1"
#    key            = "aws/root/s3/terraform.tfstate"
#    region         = "ap-east-1"
#    encrypt        = true
#  }
}

provider "aws" {
  alias  = "hk"
  region  = var.aws_region
}
