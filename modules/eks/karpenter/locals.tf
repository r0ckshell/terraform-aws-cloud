locals {
  module_tags = {
    terraform-module      = "eks/karpenter"
    terraform-aws-modules = "terraform-aws-modules/eks/aws//modules/karpenter"
    UsedBy                = "eks/${var.cluster_name}"
  }
  tags = merge(var.tags, local.module_tags)
}
