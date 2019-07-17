provider "aws" {
  profile   = "default"  
  region  = "${var.region}"
}

#Network

resource "aws_vpc" "main" {
  cidr_block       = "${var.cidr_block}"
  
  tags = {
    Name = "VPC Principal"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = "${aws_vpc.main.id}"

  tags = {
    Name = "Gw Default"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.10.1.0/24"
  
  availability_zone = "${var.region}a"

  tags = {
    Name = "Public 1a"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id     = "${aws_vpc.main.id}"
  cidr_block = "10.10.2.0/24"
  availability_zone = "${var.region}b"

  tags = {
    Name = "Public 1b"
  }
}


resource "aws_route_table" "public" {
  vpc_id = "${aws_vpc.main.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.gw.id}"
  }

  
  tags = {
    Name = "Route Public"
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = "${aws_subnet.public_a.id}"
  route_table_id = "${aws_route_table.public.id}"
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = "${aws_subnet.public_b.id}"
  route_table_id = "${aws_route_table.public.id}"
}


#Security
resource "aws_security_group" "instance_sg" {
    name    = "instance_sg"
    vpc_id  = "${aws_vpc.main.id}"
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        security_groups = ["${aws_security_group.lb.id}"]
    }
 

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  
}

resource "aws_security_group" "lb" {
    name    = "web"
    vpc_id  = "${aws_vpc.main.id}"
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

   

    ingress {
        from_port   = 443
        to_port     = 443
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


#ALB
resource "aws_alb" "alb_default" {
  name                = "alb-default"
  load_balancer_type  = "application"
  internal            =  false
  subnets = ["${aws_subnet.public_a.id}", "${aws_subnet.public_b.id}"]
  security_groups    = ["${aws_security_group.lb.id}"]
 
}

resource "aws_alb_target_group" "alb_target_group" {
  protocol    = "HTTP"
  port        = 80
  vpc_id      = "${aws_vpc.main.id}"
  target_type = "instance"

  health_check {    
    healthy_threshold   = 5    
    unhealthy_threshold = 2    
    timeout             = 5    
    interval            = 30    
    path                = "/"    
    port                = 80
    matcher             ="200"
  }
  
}

resource "aws_alb_target_group_attachment" "alb_target_srv_nginx" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.srv_nginx.id}"
  port             = 80
}

resource "aws_alb_target_group_attachment" "alb_target_srv_tomcat" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.srv_tomcat.id}"
  port             = 80
}


resource "aws_alb_listener" "alb_listener_80" {
  load_balancer_arn = "${aws_alb.alb_default.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}

#AMI/Instances
/* resource "aws_ami_copy" "ami_ubuntu" {
  name              = "ami_ubuntu"
  description       = "A copy of ami-026c8acd92718196b"
  source_ami_id     = "ami-026c8acd92718196b"
  source_ami_region = "us-east-1"
 }*/

resource "aws_instance" "srv_nginx" {
  #ami                    = "${aws_ami_copy.ami_ubuntu.id}"
  ami                         = "ami-026c8acd92718196b"
  instance_type               = "t2.micro"
  vpc_security_group_ids      = ["${aws_security_group.instance_sg.id}"]
  associate_public_ip_address = true
  subnet_id                   = "${aws_subnet.public_a.id}"
  user_data                   = "${file("install_nginx.sh")}"
  tags = {
      Name = "srv-nginx"
  }  
}

resource "aws_instance" "srv_tomcat" {
  #ami                    = "${aws_ami_copy.ami_ubuntu.id}"
  ami                         = "ami-026c8acd92718196b"
  instance_type               = "t2.micro"
  subnet_id                   = "${aws_subnet.public_b.id}"
  vpc_security_group_ids      = ["${aws_security_group.instance_sg.id}"]
  associate_public_ip_address = true
  
  user_data              = "${file("install_apache.sh")}"
  tags = {
      Name = "srv-tomcat"
  }  
}


#module
terraform {
  backend "s3" {
    bucket         = "com.challengetiendanube.dev.terraform"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform_dev"
  }
}

