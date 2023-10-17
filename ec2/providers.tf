terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }

  backend "s3" {
    bucket = "learning-terraform-state-2023"
    key    = "learning.terraform.tfstate"
    region = "ap-east-1"
  }
}

provider "aws" {
  region  = "ap-east-1"
}
