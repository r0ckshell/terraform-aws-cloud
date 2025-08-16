module "aws_eks_karpenter" {
  count = var.create ? 1 : 0

  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "~> 21.0"

  ## A unique name is formed from the cluster name.
  ## Disable prefixes for everything to improve readability.
  ##
  iam_role_use_name_prefix      = false
  iam_policy_use_name_prefix    = false
  node_iam_role_use_name_prefix = false

  iam_role_name      = "${var.cluster_name}.KarpenterControllerRole"
  iam_policy_name    = "${var.cluster_name}.KarpenterControllerPolicy"
  node_iam_role_name = "${var.cluster_name}.KarpenterNodeRole"
  queue_name         = "${var.cluster_name}EKSKarpenterQueue"
  # rule_name_prefix = "${var.cluster_name}EKSKarpenterRule"

  node_iam_role_additional_policies = var.node_iam_role_additional_policies

  enable_spot_termination = true
  service_account         = "eks-${var.cluster_name}-karpenter"

  cluster_name = var.cluster_name
  namespace    = var.namespace

  tags = local.tags
}

resource "helm_release" "karpenter" {
  count = var.create ? 1 : 0

  name       = "karpenter"
  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"
  version    = "1.6.1"

  create_namespace = true
  namespace        = var.namespace

  values = [templatefile("${path.module}/helm/values.yaml", {
    cluster_name     = "${var.cluster_name}"
    cluster_endpoint = "${var.cluster_endpoint}"
    queue_name       = "${module.aws_eks_karpenter[0].queue_name}"

    service_account = "${module.aws_eks_karpenter[0].service_account}"
    iam_role_arn    = "${module.aws_eks_karpenter[0].iam_role_arn}"

    replicas = var.on_spot_nodes ? 2 : 1
  })]

  cleanup_on_fail = true
  atomic          = true
}

resource "kubernetes_manifest" "karpenter_node_pool" {
  count = var.create ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/yamls/NodePool.yaml", {}))

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "karpenter_ec2_node_class" {
  count = var.create ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/yamls/EC2NodeClass.yaml", {
    iam_role_name    = "${module.aws_eks_karpenter[0].node_iam_role_name}"
    data_volume_size = "32Gi"
  }))

  depends_on = [
    helm_release.karpenter
  ]
}

resource "kubernetes_manifest" "test_deployment" {
  count = var.create && var.create_test_resources ? 1 : 0

  manifest = yamldecode(templatefile("${path.module}/yamls/test-deployment.yaml", {}))

  depends_on = [
    helm_release.karpenter
  ]
}
