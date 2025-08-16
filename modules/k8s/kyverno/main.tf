resource "helm_release" "kyverno" {
  count = var.create ? 1 : 0

  name       = "kyverno"
  repository = "https://kyverno.github.io/kyverno"
  chart      = "kyverno"
  version    = "3.5.0" # https://github.com/kyverno/kyverno/tags

  create_namespace = true
  namespace        = "kyverno"

  values = try([templatefile("${path.module}/helm/values.yaml", {})], [])

  cleanup_on_fail = true
  atomic          = true
}

## CRDs must be installed first.
##
# resource "kubernetes_manifest" "this" {
#   for_each = var.create ? local.kubernetes_manifests : {}

#   manifest = each.value

#   depends_on = [
#     helm_release.kyverno
#   ]
# }
