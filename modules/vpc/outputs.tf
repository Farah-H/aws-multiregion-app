output "public_subnets" {
  value = module.vpc.public_subnets
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "azs" {
  value = slice(data.aws_availability_zones.available.names, 0, 3)
}