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
      version = ">= 3.22.0"
    }

    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}