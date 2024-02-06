# this locals block is more of a stylistic decision, it makes it easy to see what variables need or should
# be changed when duplicating to another region 
locals {
  vpc_cidr       = "10.11.10.0/24"
  public_subnets = ["10.11.10.0/27", "10.11.10.32/27", "10.11.10.64/27"]
}

# dynamically source ami, because the ids are different for every region
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

module "vpc" {
  source = "../modules/vpc"

  vpc_cidr       = local.vpc_cidr
  public_subnets = local.public_subnets
}

resource "aws_security_group" "webserver" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port       = "80"
    to_port         = "80"
    protocol        = "tcp"
    security_groups = [aws_security_group.webserver_lb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "webserver_lb" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}