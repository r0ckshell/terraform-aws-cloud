module "aws_eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.24.1" # https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  vpc_id          = var.vpc_id
  subnet_ids      = var.private_subnets # Nodes and Control plane (ENIs) will be provisioned in these subnets.

  ## A unique name is formed from the cluster name.
  ## Disable prefixes for everything to improve readability.
  ##
  cluster_security_group_use_name_prefix    = false
  node_security_group_use_name_prefix       = false
  iam_role_use_name_prefix                  = false
  cluster_encryption_policy_use_name_prefix = false

  cluster_endpoint_public_access = true

  enable_cluster_creator_admin_permissions = true

  ### Control Plane security group
  ## The module creates a "Cluster security group," which is the primary security group for the cluster, including EKS Control Plane master nodes and any managed workloads.
  ## The group declared here is one of the "Additional Security Groups" and is not automatically assigned to workloads like the Cluster security group does.
  ## Since the "Cluster security group" is only used to allow workloads in the cluster to communicate with each other and the Control plane,
  ## an "Additional security group" is used to configure a connection to the Control plane (443/HTTPS - Kubernetes API server, default) from outside.
  ## 
  cluster_security_group_name        = "${var.cluster_name}.EKSControlPlane"
  cluster_security_group_description = "EKS Control Plane security group"
  cluster_security_group_additional_rules = {
    vpc = {
      description = "Allow incoming connections to any port within the VPC."
      type        = "ingress"
      from_port   = 0
      to_port     = 0
      protocol    = -1
      cidr_blocks = ["${var.vpc_cidr_block}"]
    }
  }

  ### Worker Nodes security group
  ##
  node_security_group_name                     = "${var.cluster_name}.EKSWorkerNode"
  node_security_group_description              = "EKS Worker Node security group"
  node_security_group_enable_recommended_rules = true

  ### Cluster IAM Role
  ##
  iam_role_name = "${var.cluster_name}.EKSControlPlaneRole"
  # iam_role_additional_policies = {}

  ### Encryption of cluster Secrets
  ##
  kms_key_deletion_window_in_days = 7 # 30 by default

  cluster_encryption_policy_name = "${var.cluster_name}.EKSClusterEncryptionPolicy"

  ### EKS Managed Node Groups
  ## Do not use this shit. never
  eks_managed_node_group_defaults = {}
  eks_managed_node_groups         = {}

  cluster_security_group_tags    = local.tags
  node_security_group_tags       = local.tags
  iam_role_tags                  = local.tags
  cluster_encryption_policy_tags = local.tags
  tags                           = local.tags
}

### Create IAM Role for EKS Workers
##
resource "aws_iam_role" "EKSWorkerNodeRole" {
  name               = local.EKSWorkerNodeRole.name
  assume_role_policy = local.EKSWorkerNodeRole.assume_role_policy

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "EKSWorkerNodeRole" {
  for_each = local.EKSWorkerNodeRole.attachments

  role       = aws_iam_role.EKSWorkerNodeRole.name
  policy_arn = each.value

  depends_on = [
    aws_iam_role.EKSWorkerNodeRole,
  ]
}

### Get the latest version of EKS AMI
##
data "aws_ssm_parameter" "eks_ami_release_version" {
  name = "/aws/service/eks/optimized-ami/${module.aws_eks.cluster_version}/amazon-linux-2/recommended/release_version"
}

### Create EKS Node Groups
##
resource "aws_eks_node_group" "this" {
  for_each = var.node_groups

  cluster_name  = module.aws_eks.cluster_name
  node_role_arn = aws_iam_role.EKSWorkerNodeRole.arn
  subnet_ids    = var.private_subnets

  node_group_name = each.value.name
  ami_type        = each.value.ami_type
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
      key    = "${taint.value.key}"
      value  = "${taint.value.value}"
      effect = "${taint.value.effect}"
    }
  }

  update_config {
    max_unavailable = 1 # default value
  }

  tags = local.tags

  depends_on = [
    module.aws_eks,
    aws_iam_role_policy_attachment.EKSWorkerNodeRole,
  ]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      scaling_config[0].desired_size,
      scaling_config[0].max_size,
    ]
  }
}

### Get the recommended version and install EKS addons
##
data "aws_eks_addon_version" "this" {
  for_each = local.addons

  addon_name         = each.key
  kubernetes_version = module.aws_eks.cluster_version
  # most_recent        = true # Uncomment to use the latest version
}

resource "aws_eks_addon" "this" {
  for_each = local.addons

  cluster_name                = module.aws_eks.cluster_name
  addon_name                  = each.key
  addon_version               = data.aws_eks_addon_version.this[each.key].version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = local.tags

  depends_on = [
    module.aws_eks,
    aws_eks_node_group.this, # It is necessary to wait until at least one node group is created.
  ]
}

### Generate kubeconfig
##
resource "null_resource" "kubeconfig" {
  ## Uncomment to update kubeconfig every time terraform is applied.
  # triggers = {
  #   always_run = timestamp()
  # }
  provisioner "local-exec" {
    command = "aws eks update-kubeconfig --region ${var.region} --name ${var.cluster_name} --kubeconfig ${var.kubeconfig_path}"
    environment = {
      AWS_REGION            = var.region
      AWS_ACCESS_KEY_ID     = var.access_key
      AWS_SECRET_ACCESS_KEY = var.secret_key
    }
  }

  depends_on = [
    module.aws_eks,
  ]
}
