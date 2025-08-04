locals {
  module_tags = {
    terraform-module = "k8s"
    UsedBy           = "eks/${var.cluster_name}"
  }
  tags = merge(var.tags, local.module_tags)

  namespaces = [
    "ingress-nginx",
    "cert-manager",
    "hashicorp",
    "chartmuseum",
    "metrics",
  ]

  charts = try(yamldecode(file("${path.module}/helm/charts.yaml")), {})

  iam_policy_files = fileset("${path.module}/iam_policies", "*.json")

  iam_roles = {
    EKSChartMuseumS3AccessRole = {
      name = "${var.cluster_name}.EKSChartMuseumS3AccessRole"
      assume_role_policy = templatefile("${path.module}/iam_roles/EKSChartMuseumS3AccessRole.json", {
        account_id   = "${data.aws_caller_identity.current.account_id}"
        cluster_oidc = replace("${var.cluster_oidc}", "https://", "")
      })
      attachments = {
        EKSChartMuseumS3Access = aws_iam_policy.this["EKSChartMuseumS3Access.json"].arn
      }
    }
  }

  service_accounts = {
    chartmuseum = {
      namespace    = "chartmuseum"
      iam_role_arn = aws_iam_role.this["EKSChartMuseumS3AccessRole"].arn
    }
  }
}
