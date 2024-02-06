output "nginx_domain" {
  value = "http://${aws_instance.webserver.public_dns}"
}
