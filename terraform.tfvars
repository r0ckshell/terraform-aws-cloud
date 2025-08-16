### AWS (deployer keys)
## TODO: Use AWS_PROFILE instead of AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
##
AWS_REGION            = "<aws-region>"
AWS_ACCESS_KEY_ID     = "<aws-access-key-id>"
AWS_SECRET_ACCESS_KEY = "<aws-secret-access-key>"

### VPC
##
vpc_name             = "main"
azs                  = ["us-east-1a", "us-east-1b", "us-east-1c"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

### EKS
##
cluster_name       = "main"
kubernetes_version = "1.33"

### K8S
##
vault_addr         = "hv.domain.com"
chartmuseum_domain = "cm.domain.com"

### EC2s
##
ami = "ami-0b947c5d5516fa06e" # Amazon Linux 2023 (ARM)

### For first run it would be nice to create test resources.
## This will create test deployments and other resources that will show if everything is configured correctly.
##
create_test_resources = true
