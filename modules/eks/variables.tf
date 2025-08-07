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
variable "kubernetes_version" {
  type = string
}

### Tags
##
variable "tags" {
  type = map(string)
}
