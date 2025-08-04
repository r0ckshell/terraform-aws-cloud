### AWS resources
## Generate postfix for ChartMuseum S3 Bucket
##
resource "random_string" "chartmuseum" {
  length  = 4
  special = false
  upper   = false
}

## Generate password
##
resource "random_password" "chartmuseum" {
  length  = 16
  special = true
}

## Create S3 bucket for ChartMuseum
##
resource "aws_s3_bucket" "chartmuseum" {
  bucket = format("%s-%s", "chartmuseum", random_string.chartmuseum.result)

  tags = local.tags
}

## Create IAM policies for the IAM roles used by the service accounts
##
resource "aws_iam_policy" "this" {
  for_each = local.iam_policy_files

  name = replace("${var.cluster_name}.${each.key}", ".json", "")
  policy = templatefile("${path.module}/iam_policies/${each.key}", {
    cluster_arn        = "${var.cluster_arn}"
    chartmuseum_bucket = "${aws_s3_bucket.chartmuseum.arn}"
  })

  tags = local.tags

  depends_on = [
    aws_s3_bucket.chartmuseum,
  ]
}

## Get account_id to create IAM roles
##
data "aws_caller_identity" "current" {}

resource "aws_iam_role" "this" {
  for_each           = local.iam_roles
  name               = each.value.name
  assume_role_policy = each.value.assume_role_policy
}

module "policy_attachment" {
  for_each = local.iam_roles
  source   = "./policy_attachment"

  role        = each.value.name
  attachments = local.iam_roles[each.key].attachments

  depends_on = [
    aws_iam_policy.this,
    aws_iam_role.this,
  ]
}

### K8S resources
## Create namespaces
##
resource "kubernetes_namespace" "this" {
  for_each = toset(local.namespaces)

  metadata {
    labels = {
      Name      = each.key
      CreatedBy = "Terraform"
    }

    name = each.key
  }
}

## Deploy helm charts
##
resource "helm_release" "this" {
  for_each = local.charts

  name       = each.value.name
  repository = each.value.repository
  chart      = each.value.chart
  version    = each.value.version
  namespace  = each.value.namespace

  cleanup_on_fail = true
  atomic          = true

  values = try([
    templatefile("${path.module}/helm/${each.value.name}/values.yaml", {
      # ingress-nginx
      balancer_subnets = join(", ", var.public_subnets)
      # chartmuseum
      aws_region            = "${var.aws_region}"
      chartmuseum_bucket    = "${aws_s3_bucket.chartmuseum.id}"
      chartmuseum_auth_user = "admin"
      chartmuseum_auth_pass = "${random_password.chartmuseum.result}"
      chartmuseum_domain    = "${var.chartmuseum_domain}"
      # hashicorp vault
      externalVaultAddr = "${var.vault_addr}"
    })
  ], [])

  dynamic "set" {
    for_each = try(each.value.set, {})
    content {
      name  = set.value.name
      value = set.value.value
    }
  }

  wait_for_jobs = true
  timeout       = 180

  depends_on = [
    kubernetes_namespace.this,
    kubernetes_service_account.this,
  ]
}

resource "kubernetes_service_account" "this" {
  for_each = local.service_accounts
  metadata {
    name      = each.key
    namespace = each.value.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = try(each.value.iam_role_arn, "")
    }
  }

  depends_on = [
    aws_iam_role.this,
    kubernetes_namespace.this,
  ]
}
