# Information about the AMI
data "aws_ami" "app_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ami_filter.name]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [var.ami_filter.owner] # Bitnami
}

# Default VPC security group
data "aws_vpc" "default" {
  default = true
}

# Create an instance
#resource "aws_instance" "blog" {
#  ami           = data.aws_ami.app_ami.id
#  instance_type = var.instance_type
#
#  # Associate the instance with the VPC
#  vpc_security_group_ids = [module.blog_security_group.security_group_id]
#  subnet_id = module.blog_vpc.public_subnets[0] # Required
#
#  tags = {
#    Name = "Learning terraform"
#  }
#}

# ---- Modules --------------------------------------------------------------------------------

module "blog_autoscaling" {
  source  = "terraform-aws-modules/autoscaling/aws"
  version = "6.5.2"

  name = "${var.environment.name}-blog-autoscaling"

  min_size            = var.asg_min
  max_size            = var.asg_max
  vpc_zone_identifier = module.blog_vpc.public_subnets
  target_group_arns   = module.blog_alb.target_group_arns
  security_groups     = [module.blog_security_group.security_group_id]
  instance_type       = var.instance_type
  image_id            = data.aws_ami.app_ami.id
}

# Create an ALB (load balancer)
module "blog_alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 6.0"

  name = "${var.environment.name}-blog-alb"

  load_balancer_type = "application"

  vpc_id             = module.blog_vpc.vpc_id
  subnets            = module.blog_vpc.public_subnets
  security_groups    = [module.blog_security_group.security_group_id]

  target_groups = [
    {
      name_prefix      = "${var.environment.name}-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = var.environment.name
  }
}

# Create a VPC
module "blog_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.environment.name
  cidr = "${var.environment.network_prefix}.0.0/16"

  azs             = ["ap-east-1a", "ap-east-1b", "ap-east-1c"]
  public_subnets = [
    "${var.environment.network_prefix}.101.0/24",
    "${var.environment.network_prefix}.102.0/24",
    "${var.environment.network_prefix}.103.0/24"]

  # Uncomment this to create a NAT gateway
  #  enable_nat_gateway = true
  #  single_vpn_gateway = true

  tags = {
    Terraform = true,
    Environment = var.environment.name
  }
}

# Create a security group
module "blog_security_group" {
  source = "terraform-aws-modules/security-group/aws"

  name        = "${var.environment.name}-blog-security-group}"
  description = "Allow HTTP and HTTPS inbound traffic. And allow all outbound traffic."

  vpc_id      = module.blog_vpc.vpc_id

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
