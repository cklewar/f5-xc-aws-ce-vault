provider "aws" {
  alias  = "default"
  region = var.aws_region
}

module "vault_vpc" {
  source             = "../modules/aws/vpc"
  aws_owner          = var.owner_tag
  aws_region         = var.aws_region
  aws_az_name        = format("%s%s", var.aws_region, var.aws_zone)
  aws_vpc_name       = format("%s-%s", var.project_prefix, var.aws_vpc_client_name)
  aws_vpc_cidr_block = var.aws_vpc_vault_cidr_block
  create_igw         = true
  custom_tags        = local.custom_tags
  providers          = {
    aws = aws.default
  }
}

module "vault_subnets" {
  source          = "../modules/aws/subnet"
  aws_vpc_id      = module.vault_vpc.aws_vpc["id"]
  aws_vpc_subnets = [
    {
      name                     = format("%s-%s-public", var.project_prefix, var.aws_vpc_client_name)
      owner                    = var.owner_tag
      igw_id                   = module.vault_vpc.aws_vpc["igw_id"]
      cidr_block               = var.aws_vault_instance_subnet_public
      custom_tags              = local.custom_tags
      availability_zone        = format("%s%s", var.aws_region, var.aws_zone)
      map_public_ip_on_launch  = true
      create_igw_default_route = true
    }
  ]
  providers = {
    aws = aws.default
  }
}

module "aws_security_group_vault_instance_public" {
  source                      = "../modules/aws/security_group"
  description                 = "SG Generator outside interface"
  aws_vpc_id                  = module.vault_vpc.aws_vpc["id"]
  aws_security_group_name     = format("%s-%s-public", var.project_prefix, var.aws_ec2_vault_instance_name)
  security_group_rules_egress = [
    {
      ip_protocol = -1
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  security_group_rules_ingress = [
    {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      from_port   = 8200
      to_port     = 8200
      ip_protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
  providers = {
    aws = aws.default
  }
}

module "vault" {
  source                           = "../modules/aws/ec2"
  owner                            = var.owner_tag
  custom_tags                      = local.custom_tags
  aws_region                       = var.aws_region
  aws_az_name                      = format("%s%s", var.aws_region, "a")
  aws_ec2_instance_name            = format("%s-%s", var.project_prefix, var.aws_ec2_vault_instance_name)
  aws_ec2_instance_type            = var.aws_ec2_vault_instance_type
  aws_ec2_instance_script_file     = var.aws_ec2_vault_instance_script_file_name
  aws_ec2_instance_script_template = var.aws_ec2_vault_instance_script_template_file_name
  aws_ec2_instance_script          = {
    actions = [
      format("chmod +x /tmp/%s", format("%s", var.aws_ec2_vault_instance_script_file_name)),
      format("sudo /tmp/%s", format("%s", var.aws_ec2_vault_instance_script_file_name))
    ]
    template_data = {}
  }
  aws_ec2_network_interfaces = [
    {
      create_eip      = true
      private_ips     = [var.aws_ec2_vault_instance_public_ip]
      subnet_id       = module.vault_subnets.aws_subnets[0]["id"]
      custom_tags     = local.custom_tags
      security_groups = [module.aws_security_group_vault_instance_public.aws_security_group["id"]]
    }
  ]
  aws_ec2_instance_custom_data_dirs = [
    {
      name        = "instance_script"
      source      = "${local.template_output_dir_path}/${var.aws_ec2_vault_instance_script_file_name}"
      destination = format("/tmp/%s", var.aws_ec2_vault_instance_script_file_name)
    }
  ]
  ssh_private_key          = file(var.ssh_private_key_file)
  ssh_public_key           = file(var.ssh_public_key_file)
  template_input_dir_path  = local.template_input_dir_path
  template_output_dir_path = local.template_output_dir_path
  providers                = {
    aws = aws.default
  }
}