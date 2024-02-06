resource "aws_launch_configuration" "webserver" {
  name_prefix                 = "previse-webserver-launch-config"
  image_id                    = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  security_groups             = [aws_security_group.webserver.id]
  user_data                   = <<EOF
#!/bin/bash
sudo su -
apt update -y &&
apt install -y nginx
systemctl start nginx
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_elb" "webserver" {
  name            = "previse-elb"
  security_groups = [aws_security_group.webserver_lb.id]
  subnets         = module.vpc.public_subnets


  health_check {
    healthy_threshold   = 3
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    target              = "HTTP:80/"
  }

  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = "80"
    instance_protocol = "http"
  }
}

resource "aws_autoscaling_group" "webserver" {
  launch_configuration = aws_launch_configuration.webserver.name
  vpc_zone_identifier  = module.vpc.public_subnets

  max_size         = 3
  min_size         = 3
  desired_capacity = 3

  default_instance_warmup   = 60
  health_check_grace_period = 60

  load_balancers        = [aws_elb.webserver.id]
  max_instance_lifetime = 604800 # 7 days 

  tag {
    key                 = "Name"
    value               = "previse_webserver"
    propagate_at_launch = true
  }
}
