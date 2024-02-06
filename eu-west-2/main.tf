# this locals block is more of a stylistic decision, it makes it easy to see what variables need or should
# be changed when duplicating to another region 
locals {
  vpc_cidr       = "10.10.10.0/24"
  public_subnets = ["10.10.10.0/27", "10.10.10.32/27", "10.10.10.64/27"]
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

resource "aws_instance" "webserver" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  vpc_security_group_ids      = [aws_security_group.webserver.id]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  user_data                   = <<EOF
#!/bin/bash
sudo su -
apt update -y &&
apt install -y nginx
systemctl start nginx
EOF

  tags = {
    Name = "previse-nginx"
  }
}

resource "aws_security_group" "webserver" {
  vpc_id = module.vpc.vpc_id

  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "443"
    to_port     = "443"
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
