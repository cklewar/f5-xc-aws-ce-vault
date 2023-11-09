output "ssh_host" {
  value = module.vault.aws_ec2_instance["public_ip"]
}