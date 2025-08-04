### VPC
##
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}

### EC2s
##
variable "ec2_instances" {}
variable "security_groups" {}
variable "ssh_key_name" {
  type = string
}

### Tags
##
variable "tags" {
  type = map(string)
}
