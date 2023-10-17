terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "learning-terraform-state-2023"
    key    = "learning.terraform.tfstate"
    region = var.aws_region
  }
}

provider "aws" {
  alias  = "hk"
  region  = var.aws_region
}
