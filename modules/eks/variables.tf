### AWS
##
variable "region" {
  type = string
}
variable "access_key" {
  type = string
}
variable "secret_key" {
  type = string
}

### VPC
##
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}

### EKS
##
variable "cluster_name" {
  type = string
}
variable "cluster_version" {
  type = string
}
variable "kubeconfig_path" {
  type = string
}
variable "node_groups" {
  description = "EKS Node Groups configuration"
  type = map(object({
    name           = string
    ami_type       = string
    instance_types = list(string)
    capacity_type  = string
    disk_size      = number
    scaling_config = object({
      min_size     = number
      desired_size = number
      max_size     = number
    })
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
    })))
    release_version = optional(string)
  }))
  default = {}
}

### Tags
##
variable "tags" {
  type = map(string)
}
