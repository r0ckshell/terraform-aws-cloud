## AWS
##
variable "AWS_REGION" {
  type        = string
  description = "AWS_REGION"
  default     = "us-east-1"
}
variable "AWS_PROFILE" {
  type        = string
  description = "AWS_PROFILE"
  default     = "default"
}

## VPC
##
variable "vpc_name" {
  type        = string
  description = "VPC Name"
  default     = "main"
}
variable "azs" {
  type        = list(string)
  description = "Availability Zones"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}
variable "cidr" {
  type        = string
  description = "VPC CIDR, default: 10.0.0.0/16"
  default     = "10.0.0.0/16"
}
variable "public_subnet_cidrs" {
  type        = list(string)
  description = "Public Subnet CIDR values, default: [ 10.0.1.0/24 10.0.2.0/24 ]"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR values, default: [ 10.0.101.0/24 10.0.102.0/24 ]"
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

## EKS
##
variable "cluster_name" {
  type        = string
  description = "Cluster Name"
  default     = "main"
}
variable "kubernetes_version" {
  type        = string
  description = "Kubernetes version"
  default     = "1.33"
}
variable "use_karpenter" {
  type        = bool
  description = "Whether to use Karpenter for node management"
  default     = true
}

## K8S
##
variable "vault_addr" {
  type        = string
  description = "Hashicorp Vault server domain name"
}
variable "chartmuseum_domain" {
  type        = string
  description = "Chartmuseum server domain name"
}

## EC2s
##
variable "ami" {
  type        = string
  description = "Amazon Machine Image, default: Amazon Linux 2023 64-bit (ARM)"
  default     = "ami-0b947c5d5516fa06e"
}

## Test Resources
##
variable "create_test_resources" {
  type        = bool
  description = "Whether to create test resources"
  default     = false
}
