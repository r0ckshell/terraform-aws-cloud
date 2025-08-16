locals {
  yaml_files = fileset("${path.module}/yamls", "*.yaml")
  kubernetes_manifests = {
    for file in local.yaml_files : replace(file, ".yaml", "") => try(yamldecode(file("${path.module}/yamls/${file}")), {})
  }
}
