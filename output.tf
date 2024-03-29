output "ip-srv-nginx" {
  value = "${aws_instance.srv_nginx.public_ip}"
}

output "ip-srv-tomcat" {
  value = "${aws_instance.srv_tomcat.public_ip}"
}

output "alb-server" {
  value = "${aws_alb.alb_default.dns_name}"
  
}



