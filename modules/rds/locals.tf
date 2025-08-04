locals {
  module_tags = {
    terraform-module = "rds"
  }
  tags = merge(var.tags, local.module_tags)
}
