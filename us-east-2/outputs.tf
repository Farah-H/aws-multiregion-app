output "nginx_domain" {
  value = "http://${aws_elb.webserver.dns_name}"
}