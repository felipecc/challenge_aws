provider "aws" {
  profile   = "default"  
  region  = "${var.region}"
}



data "aws_availability_zones" "available" {}

resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

data "aws_subnet_ids" "all" {
  vpc_id = "${aws_default_vpc.default.id}"
}



#Segurança
resource "aws_security_group" "default_ca" {
    name    = "default_ca"
    vpc_id  = "${aws_default_vpc.default.id}"
    ingress {
        from_port   = 80
        to_port     = 80
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

resource "aws_security_group" "sg_instance" {
    name    = "sg_instance"
    vpc_id  = "${aws_default_vpc.default.id}"
    
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port   = 32768
        to_port     = 61000
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]

        security_groups = [
          "${aws_security_group.default_ca.id}",
        ]

    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }  

}


#Alb

resource "aws_alb" "alb_default" {
  name      = "alb-default"
  internal  =  false
  subnets = ["${data.aws_subnet_ids.all.ids}"]
  security_groups    = ["${aws_security_group.default_ca.id}"]
 
}

resource "aws_alb_target_group" "alb_target_group" {
  protocol    = "HTTP"
  port        = 80
  vpc_id      = "${aws_default_vpc.default.id}"
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
  port             = 8080
}

resource "aws_alb_target_group_attachment" "alb_target_srv_tomcat" {
  target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
  target_id        = "${aws_instance.srv_tomcat.id}"
  port             = 80
}


resource "aws_alb_listener" "alb_listener" {
  load_balancer_arn = "${aws_alb.alb_default.arn}"
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.alb_target_group.arn}"
    type             = "forward"
  }
}


resource "aws_instance" "srv_nginx" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_instance.id}"]
  user_data              = "${file("install_nginx.sh")}"
  tags = {
      Name = "srv-nginx"
  }  
}

resource "aws_instance" "srv_tomcat" {
  ami                    = "ami-0b898040803850657"
  instance_type          = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.sg_instance.id}"]
  
  user_data              = "${file("install_apache.sh")}"
  tags = {
      Name = "srv-tomcat"
  }  
}






