variable "vpc_name" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "cidr" {
  type = string
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "use_karpenter" {
  description = "Whether to add karpenter.sh/discovery tag to private subnets"
  type        = bool
  default     = true
}

variable "tags" {
  type = map(string)
}
