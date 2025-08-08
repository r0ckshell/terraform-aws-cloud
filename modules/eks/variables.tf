variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "private_subnets" {
  type = list(string)
}

variable "cluster_name" {
  type = string
}
variable "kubernetes_version" {
  type = string
}

variable "tags" {
  type = map(string)
}
