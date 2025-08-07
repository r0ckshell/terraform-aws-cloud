module "vpc" {
  source               = "./modules/vpc"
  cidr                 = var.cidr
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  vpc_name             = local.vpc_name

  tags = local.tags
}

module "ec2s" {
  source          = "./modules/ec2s"
  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
  ec2_instances   = local.ec2_instances
  security_groups = local.ec2s_security_groups
  ssh_key_name    = local.ec2s_ssh_key_name

  tags = local.tags
}

module "rds" {
  source          = "./modules/rds"
  vpc_id          = module.vpc.vpc_id
  vpc_cidr_block  = module.vpc.vpc_cidr_block
  subnet_ids      = module.vpc.private_subnets
  security_groups = local.rds_security_groups
  databases       = local.databases

  tags = local.tags
}

module "eks" {
  source             = "./modules/eks"
  kubernetes_version = var.kubernetes_version
  vpc_id             = module.vpc.vpc_id
  vpc_cidr_block     = module.vpc.vpc_cidr_block
  private_subnets    = module.vpc.private_subnets
  cluster_name       = local.cluster_name

  tags = local.tags
}

module "tf-managed-node-groups" {
  source             = "./modules/eks/node-groups"
  kubernetes_version = var.kubernetes_version
  private_subnets    = module.vpc.private_subnets
  node_role_arn      = module.eks.node_role_arn
  cluster_name       = local.cluster_name
  node_groups        = local.tf_managed_node_groups

  tags = local.tags
}

module "k8s" {
  source             = "./modules/k8s"
  aws_region         = var.AWS_REGION
  vault_addr         = var.vault_addr
  chartmuseum_domain = var.chartmuseum_domain
  public_subnets     = module.vpc.public_subnets
  cluster_name       = module.eks.cluster_name
  cluster_arn        = module.eks.cluster_arn
  cluster_oidc       = module.eks.cluster_oidc_issuer_url

  tags = local.tags
}
