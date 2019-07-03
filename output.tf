output "ip-srv-nginx" {
  value = "${aws_instance.srv_nginx.public_ip}"
  
}

output "dns-srv-nginx" {
  value = "${aws_instance.srv_nginx.public_dns}"
}

output "ip-srv-tomcat" {
  value = "${aws_instance.srv_tomcat.public_ip}"
}

output "dns-srv-tomcat" {
  value = "${aws_instance.srv_tomcat.public_dns}"
}



