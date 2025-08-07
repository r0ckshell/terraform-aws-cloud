locals {
  module_tags = {
    terraform-module = "node-groups"
    UsedBy           = "eks/${var.cluster_name}"
  }
  tags = merge(var.tags, local.module_tags)
}
