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

provider "aws" {
  alias  = "hk"
  region  = var.aws_region
}

# Bucket for backend
resource "aws_s3_bucket" "s3_bucket_ap_east_1" {
  bucket          = var.s3_bucket_backend
  force_destroy   = true

  tags = {
    managed-by = "Terraform"
    env        = "root_account"
    source-ref = "ec2/root/_init/init.tf"
  }
}

# ACL for the bucket
resource "aws_s3_bucket_ownership_controls" "s3_backend_ownership_controls" {
  bucket = aws_s3_bucket.s3_bucket_ap_east_1.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "s3_backend_acl" {
  depends_on = [aws_s3_bucket_ownership_controls.s3_backend_ownership_controls]

  bucket = aws_s3_bucket.s3_bucket_ap_east_1.id
  acl    = "private"
}

# Versioning for the bucket
resource "aws_s3_bucket_versioning" "s3_backend_versioning" {
  bucket = aws_s3_bucket.s3_bucket_ap_east_1.id
  versioning_configuration {
    status = "Enabled"
  }
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}

# On the start, comment the block below and start `terraform init/apply`
# After the first run, uncomment the block below and start `terraform init/apply` again
# It will move the state file to the s3 bucket
terraform {
  backend "s3" {
    bucket         = "learning.terraform.tf-state.root.ap-east-1"
    key            = "aws/root/s3/terraform.tfstate"
    region         = "ap-east-1"
    encrypt        = true
  }
}
