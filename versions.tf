terraform {
  required_version = "~> 1.9.8"
  backend "s3" {
    region = "us-east-1"
    bucket = "tf-states-glhf"
    key    = "main-cluster/tfstate"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
  }
}

provider "aws" {
  region     = var.AWS_REGION
  access_key = var.AWS_ACCESS_KEY_ID
  secret_key = var.AWS_SECRET_ACCESS_KEY
}

## TODO: Use AWS_PROFILE instead of AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
##
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
    command     = "aws"
    env = {
      AWS_REGION            = var.AWS_REGION
      AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
      AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
    }
  }
}

## TODO: Use AWS_PROFILE instead of AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY.
##
provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
      command     = "aws"
      env = {
        AWS_REGION            = var.AWS_REGION
        AWS_ACCESS_KEY_ID     = var.AWS_ACCESS_KEY_ID
        AWS_SECRET_ACCESS_KEY = var.AWS_SECRET_ACCESS_KEY
      }
    }
  }
}
