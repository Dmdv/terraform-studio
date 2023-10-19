# Information about the AMI
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["bitnami-tomcat-*-x86_64-hvm-ebs-nami"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["979382823631"] # Bitnami
}

# Default VPC security group
data "aws_vpc" "default" {
  default = true
}

# Create an instance
resource "aws_instance" "blog" {
  ami           = data.aws_ami.app_ami.id
  instance_type = var.instance_type

  # Associate the instance with the VPC
  vpc_security_group_ids = [module.security_group_blog.security_group_id]
  # This is a must
  subnet_id = module.vpc_blog.public_subnets[0]

  tags = {
    Name = "Learning terraform"
  }
}

# ---- Modules --------------------------------------------------------------------------------

# Create a VPC
module "vpc_blog" {
  source = "terraform-aws-modules/vpc/aws"

  name = "dev blog VPC"
  cidr = "10.0.0.0/16"

  azs             = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  public_subnets = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  # Uncomment this to create a NAT gateway
  #  enable_nat_gateway = true
  #  single_vpn_gateway = true

  tags = {
    Terraform = true,
    Environment = "dev"
  }
}

# Create a security group
module "security_group_blog" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "blog security group"
  description = "Allow HTTP and HTTPS inbound traffic. And allow all outbound traffic."

  vpc_id      = module.vpc_blog.vpc_id

  ingress_rules            = ["http-80-tcp", "https-443-tcp"]
  ingress_cidr_blocks      = ["0.0.0.0/0"]

  egress_rules             = ["all-all"]
  egress_cidr_blocks       = ["0.0.0.0/0"]
}

# --------- Create a security group -----------------------------------------------------------
#resource "aws_security_group" "blog" {
#  name        = "blog"
#  description = "Allow HTTP and HTTPS inbound traffic. And allow all outbound traffic."
#
#  vpc_id = data.aws_vpc.default.id
#
#  tags = {
#    Name = "Learning terraform"
#  }
#}
#
## Create a security group rule for HTTP
#resource "aws_security_group_rule" "blog_http_in" {
#  type              = "ingress"
#  from_port         = 80
#  to_port           = 80
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#
#  security_group_id = aws_security_group.blog.id
#}
#
## Create a security group rule for HTTPS
#resource "aws_security_group_rule" "blog_https_in" {
#  type              = "ingress"
#  from_port         = 443
#  to_port           = 443
#  protocol          = "tcp"
#  cidr_blocks       = ["0.0.0.0/0"]
#
#  security_group_id = aws_security_group.blog.id
#}
#
## Create a security group rule for all out
#resource "aws_security_group_rule" "blog_everything_out" {
#  type              = "egress"
#  from_port         = 0
#  to_port           = 0
#  protocol          = "-1"
#  cidr_blocks       = ["0.0.0.0/0"]
#
#  security_group_id = aws_security_group.blog.id
#}
