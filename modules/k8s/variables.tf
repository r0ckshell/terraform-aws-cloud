### AWS
##
variable "aws_region" {
  type = string
}

### VPC
##
variable "public_subnets" {
  type = list(string)
}

### EKS
##
variable "cluster_name" {
  type = string
}
variable "cluster_arn" {
  type = string
}
variable "cluster_oidc" {
  type = string
}

### Helm
##
variable "vault_addr" {
  type = string
}
variable "chartmuseum_domain" {
  type = string
}

### Tags
##
variable "tags" {
  type = map(string)
}
