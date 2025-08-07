### Get the latest version of EKS AMI
## Example:
## aws ssm get-parameter --name /aws/service/bottlerocket/aws-k8s-1.31/x86_64/latest/image_id \
##   --region us-west-2 --query "Parameter.Value" --output text
##
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/bottlerocket/aws-k8s-${var.kubernetes_version}/x86_64/latest/image_id"
}

### Create EKS Node Groups
##
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name  = var.cluster_name
  node_role_arn = var.node_role_arn
  subnet_ids    = var.private_subnets

  node_group_name = each.value.name
  release_version = try(each.value.release_version, nonsensitive(data.aws_ssm_parameter.eks_ami_release_version.value))
  instance_types  = each.value.instance_types
  capacity_type   = each.value.capacity_type
  disk_size       = each.value.disk_size

  # remote_access {
  #   source_security_group_ids = [
  #     module.aws_eks.node_security_group_id,
  #   ]
  # }

  scaling_config {
    min_size     = try(each.value.scaling_config.min_size, 0)
    desired_size = try(each.value.scaling_config.desired_size, 1)
    max_size     = try(each.value.scaling_config.max_size, 4)
  }

  dynamic "taint" {
    for_each = each.value.taints != null ? each.value.taints : []
    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }

  update_config {
    max_unavailable = 1 # default value
  }

  tags = local.tags

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
      scaling_config[0].max_size,
    ]
  }
}
