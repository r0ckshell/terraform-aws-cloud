locals {
  vpc_name     = replace(lower(var.vpc_name), " ", "-")
  cluster_name = replace(lower(var.cluster_name), " ", "-")

  ### ec2s
  ## Apply the `module.vpc` first to ensure the subnet IDs are available for other modules.
  ## The VPC module (module.vpc) must be applied first to ensure that
  ## subnet values (module.vpc.public_subnets & module.vpc.private_subnets) are available.
  ## These values must be known at plan time when using for_each in module.ec2s with var.ec2_instances.
  ##
  ## TODO: Make VPC creation a separate project and gather variables from its remote state.
  ##
  ec2_instances = yamldecode(templatefile("${path.root}/configs/${terraform.workspace}/ec2s/instances.tpl", {
    public_subnet  = "${module.vpc.public_subnets[0]}",
    private_subnet = "${module.vpc.private_subnets[0]}",
    ami            = "${var.ami}"
  }))
  ec2s_security_groups = yamldecode(file("${path.root}/configs/${terraform.workspace}/ec2s/securityGroups.yaml"))
  ec2s_ssh_key_name    = "${terraform.workspace}-deployer.key"

  ### rds
  ##
  rds_security_groups = yamldecode(file("${path.root}/configs/${terraform.workspace}/rds/securityGroups.yaml"))
  databases           = yamldecode(file("${path.root}/configs/${terraform.workspace}/rds/databases.yaml"))

  ### eks
  ##
  eks_node_groups = yamldecode(file("${path.root}/configs/${terraform.workspace}/eks/nodeGroups.yaml"))
  kubeconfig_path = "${path.root}/.terraform/kube/${local.cluster_name}.k8s.yml"

  ### Default tags
  ##
  tags = {
    CreatedBy = "Terraform"
  }
}
