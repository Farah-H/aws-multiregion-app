output "nginx_domain" {
  value = "http://${aws_instance.instance.public_dns}"
}