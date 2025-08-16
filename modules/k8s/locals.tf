locals {
  module_tags = {
    terraform-module = "k8s"
    UsedBy           = "eks/${var.cluster_name}"
  }
  tags = merge(var.tags, local.module_tags)

  namespaces = {
    "ingress-nginx" = {}
    "cert-manager"  = {}
    "hashicorp"     = {}
    "metrics"       = {}
  }

  charts = try(yamldecode(file("${path.module}/helm/charts.yaml")), {})

  iam_policy_files = fileset("${path.module}/iam_policies", "*.json")

  iam_roles = {}

  service_accounts = {}
}
