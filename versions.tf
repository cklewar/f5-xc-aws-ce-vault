terraform {
  required_version = ">= 1.3.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "f5-xc-aws-ce-vault-module"
    }
  }
  
  required_providers {
    volterra = {
      source = "volterraedge/volterra"
      version = "= 0.11.23"
    }
    aws = {
      source = "hashicorp/aws"
      version = ">= 4.52.0"
    }
    vault = {
      source = "hashicorp/vault"
      version = ">= 3.15.2"
    }
    local = ">= 2.2.3"
    null = ">= 3.1.1"
  }
}