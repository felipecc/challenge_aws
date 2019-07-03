provider "aws" {
  profile   = "default"  
  region    = var.region
}


resource "aws_security_group" "default_ca" {
    name    = "default_ca"
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


resource "aws_instance" "srv_nginx" {
  ami           = "ami-0b898040803850657"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.default_ca.id}"]
  user_data = "${file("install_nginx.sh")}"
  tags = {
      Name = "srv-nginx"
  }  
}

resource "aws_instance" "srv_tomcat" {
  ami           = "ami-0b898040803850657"
  instance_type = "t2.micro"
  vpc_security_group_ids = ["${aws_security_group.default_ca.id}"]
  user_data = "${file("install_nginx.sh")}"
  tags = {
      Name = "srv-tomcat"
  }  
}






