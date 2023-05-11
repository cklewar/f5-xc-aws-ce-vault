terraform {
  required_version = ">= 1.3.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "aws-vault-module"
    }
  }

  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = ">= 3.15.2"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}