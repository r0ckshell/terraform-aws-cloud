locals {
  module_tags = {
    terraform-module      = "vpc"
    terraform-aws-modules = "terraform-aws-modules/vpc/aws"
  }
  karpenter_tags = {
    "karpenter.sh/discovery" = "true"
  }

  private_subnet_tags = var.use_karpenter ? merge(local.tags, local.karpenter_tags) : {}
  tags                = merge(var.tags, local.module_tags)
}
