data "aws_availability_zones" "available" {}

locals {
  vpc_name = "sandbox-01-vpc"
  vpc_cidr = "10.0.0.0/16"
  vpc_azs  = slice(data.aws_availability_zones.available.names, 0, 3)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = ">= 5.0.0"

  name = local.vpc_name
  cidr = local.vpc_cidr

  azs             = local.vpc_azs
  public_subnets  = [for k, v in local.vpc_azs : cidrsubnet(local.vpc_cidr, 6, k)]
  private_subnets = [for k, v in local.vpc_azs : cidrsubnet(local.vpc_cidr, 6, k + 10)]

  enable_nat_gateway   = true
  create_igw           = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

  manage_default_network_acl    = true
  default_network_acl_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_route_table    = true
  default_route_table_tags      = { Name = "${local.vpc_name}-default" }
  manage_default_security_group = true
  default_security_group_tags   = { Name = "${local.vpc_name}-default" }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
  }
}
