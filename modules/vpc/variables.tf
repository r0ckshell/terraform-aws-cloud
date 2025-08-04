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

variable "tags" {
  type = map(string)
}
