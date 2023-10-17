variable "instance_type" {
  description = "Type of EC2 instance to provision"
  default     = "t3.nano"
}

variable "environment" {
  type    = string
  default = "prod"
}

variable "aws_region" {
  description = "AWS to operate in."
  type        = string
  default     = "ap-east-1"
}
