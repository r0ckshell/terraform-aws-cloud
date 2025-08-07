variable "private_subnets" {
  description = "List of private subnets to place the EKS Node Groups"
  type        = list(string)
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}
variable "kubernetes_version" {
  description = "Kubernetes version used to get AMI release version"
  type        = string
}

variable "node_role_arn" {
  description = "ARN of the IAM Role for the EKS Node Group"
  type        = string
}
variable "node_groups" {
  description = "EKS Node Groups configuration"
  type = map(object({
    name           = string
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

variable "tags" {
  type    = map(string)
  default = {}
}
