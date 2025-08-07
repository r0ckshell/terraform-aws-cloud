locals {
  module_tags = {
    terraform-module      = "eks"
    terraform-aws-modules = "terraform-aws-modules/eks/aws"
    UsedBy                = "eks/${var.cluster_name}"
  }
  tags = merge(var.tags, local.module_tags)

  EKSWorkerNodeRole = {
    name = "${var.cluster_name}.EKSWorkerNodeRole"
    assume_role_policy = jsonencode({
      Version = "2012-10-17"
      Statement = [{
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }]
    })
    attachments = {
      AmazonEKSWorkerNodePolicy          = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
      AmazonEKS_CNI_Policy               = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
      AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
      AmazonEBSCSIDriverPolicy           = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
    }
  }
}
