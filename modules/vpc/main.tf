data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "4.0.2"

  name = "previse"
  cidr = var.vpc_cidr
  # source azs dynamically because they vary between regions and it's better than taking in as vars
  azs            = slice(data.aws_availability_zones.available.names, 0, 3)
  public_subnets = var.public_subnets

  enable_dns_hostnames = true
  enable_dns_support   = true

  create_igw = true

  manage_default_network_acl   = true
  public_dedicated_network_acl = true
  default_network_acl_name     = "default-nacl"
  default_security_group_name  = "default-sg"

  # this will allow internet connectivity outwards from the private subnets
  #   enable_nat_gateway = true
  #   single_nat_gateway = true
}

# module "endpoints" {
#     source = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
#     version = "4.0.2"

#     vpc_id = module.vpc.vpc_id
#     security_group_ids = [module.vpc.default_security_group_id]

#     endpoints = {
#         ssm = {
#             service = "ssm"
#             private_dns_enabled = true
#             subnet_ids = modules.vpc.private_subnets
#             security_group_ids = [aws]
#         }
#     }
# }