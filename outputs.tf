### VPC
##
output "vpc_id" {
  value = module.vpc.vpc_id
}
output "private_subnets" {
  value = module.vpc.private_subnets
}
output "public_subnets" {
  value = module.vpc.public_subnets
}

### EC2s
##
output "bastion_eip" {
  value = module.ec2s.bastion_eip
}

### EKS
##
output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

### K8S
##
output "chartmuseum_auth_pass" {
  value = module.k8s.chartmuseum_auth_pass
}
