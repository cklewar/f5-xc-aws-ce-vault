variable "project_prefix" {
  type        = string
  description = "prefix string put in front of string"
}

variable "aws_region" {
  type        = string
  description = "AWS region name"
}

variable "aws_zone" {
  type        = string
  description = "AWS region name"
}

variable "owner_tag" {
  type = string
}

variable "aws_vpc_vault_cidr_block" {
  type = string
}

variable "aws_vault_instance_subnet_public" {
  type = string
}

variable "aws_vpc_client_name" {
  type = string
}

variable "template_output_dir_path" {
  type    = string
  default = ""
}

variable "template_input_dir_path" {
  type    = string
  default = ""
}

variable "ssh_private_key_file_absolute" {
  type = string
}

variable "root_path" {
  type = string
}

variable "ssh_public_key_file_absolute" {
  type = string
}

variable "custom_tags" {
  type    = map(string)
  default = {}
}

variable "aws_ec2_vault_instance_name" {
  type = string
}

variable "aws_ec2_vault_instance_type" {
  type = string
}

variable "aws_ec2_vault_instance_script_file_name" {
  type = string
}

variable "aws_ec2_vault_instance_script_template_file_name" {
  type = string
}

variable "aws_ec2_vault_instance_public_ip" {
  type = string
}