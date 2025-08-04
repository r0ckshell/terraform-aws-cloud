locals {
  module_tags = {
    terraform-module      = "vpc"
    terraform-aws-modules = "terraform-aws-modules/vpc/aws"
  }
  tags = merge(var.tags, local.module_tags)
}
