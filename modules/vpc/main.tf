module "aws_vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0" # https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest

  name            = var.vpc_name
  cidr            = var.cidr
  azs             = var.azs
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs

  ## Single NAT Gateway
  ##
  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  tags = local.tags
}
