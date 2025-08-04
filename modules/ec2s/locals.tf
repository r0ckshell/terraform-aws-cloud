locals {
  ssh_key_path = "${path.cwd}/.terraform/keys/${var.ssh_key_name}"

  module_tags = {
    terraform-module      = "ec2s"
    terraform-aws-modules = "terraform-aws-modules/ec2-instance/aws"
  }
  tags = merge(var.tags, local.module_tags)
}
