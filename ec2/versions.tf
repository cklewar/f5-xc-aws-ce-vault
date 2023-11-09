terraform {
  required_version = ">= 1.3.0"
  cloud {
    organization = "cklewar"
    hostname     = "app.terraform.io"

    workspaces {
      name = "f5-xc-aws-ce-vault-module" # "f5-xc-aws-vault-ec2-module"
    }
  }

  required_providers {
    local = ">= 2.2.3"
    null  = ">= 3.1.1"
  }
}