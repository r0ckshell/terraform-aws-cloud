### VPC
##
variable "vpc_id" {
  type = string
}
variable "vpc_cidr_block" {
  type = string
}
variable "subnet_ids" {
  type = list(string)
}

### RDS
##
variable "security_groups" {}
variable "databases" {}

### Tags
##
variable "tags" {
  type = map(string)
}
