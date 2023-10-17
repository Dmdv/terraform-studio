variable "s3_bucket_backend" {
  type        = string
  description = "Terraform tfstatefile s3 bucket"
  default     = "learning.terraform.tf-state.root.ap-east-1"
}

variable "aws_region" {
  description = "AWS to operate in."
  type        = string
  default     = "ap-east-1"
}

resource "aws_s3_bucket" "bucket_ap_east_1" {
  bucket = var.s3_bucket_backend

  tags = {
    managed-by = "Terraform"
    env        = "root_account"
    source-ref = "aws/root/_init/init.tf"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

terraform {
  backend "s3" {
    encrypt        = true
    region         = "ap-east-1"
    bucket         = "learning.terraform.tf-state.root.ap-east-1"
    key            = "aws/root/s3/terraform.tfstate"
  }
}
