output "instance" {
  value = module.ec2_instance
}

output "bastion_eip" {
  value = aws_eip.this["bastion"].public_ip
}
