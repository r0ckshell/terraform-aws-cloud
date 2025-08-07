output "cluster_name" {
  value = module.aws_eks.cluster_name
}

output "cluster_arn" {
  value = module.aws_eks.cluster_arn
}

output "cluster_certificate_authority_data" {
  value = module.aws_eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  value = module.aws_eks.cluster_endpoint
}

output "cluster_oidc_issuer_url" {
  value = module.aws_eks.cluster_oidc_issuer_url
}

output "node_role_arn" {
  value = module.aws_eks.node_iam_role_arn
}
