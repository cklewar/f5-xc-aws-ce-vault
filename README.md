# AWS CLOUD CE VAULT

Terraform to create F5XC AWS Cloud CE with Vault

## Prerequisites

In order to run this use case below is needed:

- Terraform installed locally
- Vault installed locally --> Linux installation instructions: https://www.hashicorp.com/official-packaging-guide 
- An AWS account and AWS Access Credentials

## Usage

- Start the vault server
- Clone this repo with `git clone --recurse-submodules https://github.com/cklewar/f5-xc-aws-ce-vault`
- Enter repository directory with `cd f5-xc-aws-cloud-ce-vault`
- Obtain F5XC API certificate file from Console and save it to a directory where it can be read later on by F5 XC provider
- Obtain F5XC API token file from Console and provide it as Terraform input variable for later usage
- Export Vault server environment variables
  * export VAULT_TOKEN=<vault_server_token>
  * export VAULT_ADDR="<vault_server_address:port>"
- Enter `vault` directory
  * Change backend settings in `versions.tf` file to fit your environment needs. This example uses Terraform Cloud as backend system
  * Initialize with `terraform init`
  * Apply with `terraform apply -auto-approve` or destroy with `terraform destroy -auto-approve`
- Enter `ce` directory
  * Pick and choose from below examples and add mandatory input data and copy data into file `main.tf.example` in `ce` folder
  * Rename file __main.tf.example__ to __main.tf__ with `rename main.tf.example main.tf`
  * Change backend settings in `versions.tf` file to fit your environment needs. This example uses Terraform Cloud as backend system 
  * Initialize with `terraform init`
  * Apply with `terraform apply -auto-approve` or destroy with `terraform destroy -auto-approve`

## AWS Cloud CE Vault module usage example

````hcl
variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
  default     = "f5xc"
}

variable "project_suffix" {
  type        = string
  description = "prefix string put at the end of string"
  default     = "01"
}


variable "name_operator" {
  type    = string
  default = "dynamic-aws-creds-operator"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

variable "f5xc_api_p12_file" {
  type = string
}

variable "f5xc_api_url" {
  type = string
}

variable "f5xc_api_token" {
  type = string
}

variable "f5xc_tenant" {
  type = string
}

variable "f5xc_namespace" {
  type    = string
  default = "system"
}

variable "f5xc_aws_region" {
  type    = string
  default = "us-west-2"
}

variable "f5xc_aws_availability_zone" {
  type    = string
  default = "a"
}

variable "owner" {
  type    = string
  default = "c.klewar@f5.com"
}

variable "ssh_public_key_file" {
  type = string
}

variable "name" {
  type    = string
  default = "dynamic-aws-creds-operator"
}

variable "ttl" {
  type    = string
  default = "1"
}

locals {
  aws_availability_zone = format("%s%s", var.f5xc_aws_region, var.f5xc_aws_availability_zone)
  custom_tags           = {
    Owner        = var.owner
    f5xc-tenant  = var.f5xc_tenant
    f5xc-feature = "${var.project_prefix}-cloud-ce-aws-vpc-site"
  }
}

data "tfe_outputs" "vault" {
  organization = "cklewar"
  workspace    = "aws-vault-module"
}

data "vault_aws_access_credentials" "creds" {
  backend = data.tfe_outputs.vault.values.backend
  role    = data.tfe_outputs.vault.values.role
}

provider "volterra" {
  api_p12_file = var.f5xc_api_p12_file
  url          = var.f5xc_api_url
  alias        = "default"
}

provider "aws" {
  alias      = "default"
  region     = var.f5xc_aws_region
  access_key = data.vault_aws_access_credentials.creds.access_key
  secret_key = data.vault_aws_access_credentials.creds.secret_key
}

module "f5xc_aws_cloud_ce_single_node_single_nic_new_vpc_new_subnet" {
  source                = "../modules/f5xc/ce/aws"
  owner_tag             = var.owner
  is_sensitive          = false
  has_public_ip         = true
  f5xc_tenant           = var.f5xc_tenant
  f5xc_api_url          = var.f5xc_api_url
  f5xc_api_token        = var.f5xc_api_token
  f5xc_namespace        = var.f5xc_namespace
  f5xc_aws_region       = var.f5xc_aws_region
  f5xc_token_name       = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_name     = format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix)
  f5xc_cluster_labels   = { "ves.io/fleet" : format("%s-aws-ce-test-%s", var.project_prefix, var.project_suffix) }
  f5xc_aws_vpc_az_nodes = {
    node0 = {
      f5xc_aws_vpc_slo_subnet = "192.168.0.0/26",
      f5xc_aws_vpc_az_name    = local.aws_availability_zone
    }
  }
  f5xc_ce_gateway_type                 = "ingress_gateway"
  f5xc_cluster_latitude                = -73.935242
  f5xc_cluster_longitude               = 40.730610
  aws_vpc_cidr_block                   = "192.168.0.0/20"
  aws_security_group_rules_slo_egress  = []
  aws_security_group_rules_slo_ingress = []
  ssh_public_key                       = file(var.ssh_public_key_file)
  providers                            = {
    aws      = aws.default
    volterra = volterra.default
  }
}

output "f5xc_aws_secure_ce_multi_node_single_nic_existing_vpc" {
  value = module.f5xc_aws_cloud_ce_single_node_single_nic_new_vpc_new_subnet
}
````