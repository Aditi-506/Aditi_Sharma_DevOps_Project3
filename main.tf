provider "aws" {
  region = var.region
}

resource "aws_launch_configuration" "nginx_lc" {
  name_prefix     = "nginx-lc-"
  image_id        = var.ami_id
  instance_type   = var.instance_type
  security_groups = ["${aws_security_group.allow_ssh.id}", "${aws_security_group.allow_http.id}"]
  user_data       = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install nginx1.12 -y
              sudo service nginx start
              EOF
}

resource "aws_autoscaling_group" "nginx_asg" {
  name_prefix          = "nginx-asg-"
  launch_configuration = aws_launch_configuration.nginx_lc.id
  min_size             = 1
  max_size             = 3
  desired_capacity     = 2
  vpc_zone_identifier  = var.subnet_ids
  target_group_arns    = ["${aws_lb_target_group.nginx_tg.arn}"]
}

resource "aws_security_group" "allow_ssh" {
  name_prefix = "nginx-ssh-sg-"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow_http" {
  name_prefix = "nginx-http-sg-"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "nginx_lb" {
  name_prefix        = "ng-lb-"
  internal           = false
  load_balancer_type = "application"
  subnets            = var.subnet_ids
}

resource "aws_lb_target_group" "nginx_tg" {
  name_prefix = "ng-tg-"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
}

resource "aws_lb_listener" "nginx_listener" {
  load_balancer_arn = aws_lb.nginx_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_tg.arn
  }
}

output "elb_dns_name" {
  value = aws_lb.nginx_lb.dns_name
}
