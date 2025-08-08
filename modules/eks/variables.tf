#region vpc
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}
#endregion

#region eks
variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}
variable "use_karpenter" {
  type    = bool
  default = true
}
#endregion

variable "create_test_resources" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
