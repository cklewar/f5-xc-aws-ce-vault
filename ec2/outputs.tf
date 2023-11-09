output "ssh_host" {
  value = module.vault.aws_ec2_instance["public_ip"]
}

output "script_content" {
  value = module.vault.aws_ec2_instance["script_content"]
}