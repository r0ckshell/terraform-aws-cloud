bastion:
  name: "Bastion"
  instance_type: "t4g.micro"
  ami: "${ami}"
  subnet_id: "${public_subnet}"
  security_group_name: "bastion"

hashicorp_vault:
  name: "Hashicorp Vault"
  instance_type: "t4g.micro"
  ami: "${ami}"
  subnet_id: "${public_subnet}"
  security_group_name: "hashicorp-vault"
