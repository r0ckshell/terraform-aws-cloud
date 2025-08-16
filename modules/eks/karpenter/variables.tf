variable "create" {
  description = "Controls if Karpenter resources should be created"
  type        = bool
  default     = true
}

variable "cluster_name" {
  type = string
}
variable "cluster_endpoint" {
  type = string
}
variable "node_iam_role_additional_policies" {
  type    = map(string)
  default = {}
}
variable "on_spot_nodes" {
  type    = bool
  default = false
}

variable "namespace" {
  type    = string
  default = "karpenter"
}

variable "create_test_resources" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
}
