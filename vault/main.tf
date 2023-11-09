variable "name_admin" {
  type    = string
  default = "dynamic-aws-creds-vault-admin"
}

variable "aws_access_key_id" {
  type = string
}
variable "aws_secret_access_key" {
  type = string
}

provider "vault" {
  alias   = "default"
}

resource "vault_aws_secret_backend" "aws" {
  access_key                = var.aws_access_key_id
  secret_key                = var.aws_secret_access_key
  path                      = "${var.name_admin}-path"
  max_lease_ttl_seconds     = "240"
  default_lease_ttl_seconds = "120"
  provider                  = vault.default
}

resource "vault_aws_secret_backend_role" "admin" {
  name            = "${var.name_admin}-role"
  backend         = vault_aws_secret_backend.aws.path
  provider        = vault.default
  credential_type = "iam_user"
  policy_document = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "iam:*"
      ],
      "Resource": "*",
      "Sid": "IAMPermissions"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:*"
      ],
      "Resource": "*",
      "Sid": "EC2Permissions"
    },
    {
      "Action": [
          "autoscaling:AttachLoadBalancerTargetGroups",
          "autoscaling:AttachLoadBalancers",
          "autoscaling:CreateAutoScalingGroup",
          "autoscaling:CreateLaunchConfiguration",
          "autoscaling:DeleteAutoScalingGroup",
          "autoscaling:DeleteLaunchConfiguration",
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeLoadBalancerTargetGroups",
          "autoscaling:DescribeLoadBalancers",
          "autoscaling:DetachLoadBalancerTargetGroups",
          "autoscaling:DetachLoadBalancers",
          "autoscaling:DisableMetricsCollection",
          "autoscaling:EnableMetricsCollection",
          "autoscaling:ResumeProcesses",
          "autoscaling:SuspendProcesses",
          "autoscaling:UpdateAutoScalingGroup"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "AutoScalingPermissions"
    },
    {
      "Action": [
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DescribeInstanceHealth",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeLoadBalancerAttributes",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:DescribeTargetGroupAttributes",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeTargetHealth",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveTags"
      ],
      "Resource": "*",
      "Effect": "Allow",
      "Sid": "ELBPermissions"
    }
  ]
}
EOF
}

output "backend" {
  value = vault_aws_secret_backend.aws.path
}

output "role" {
  value = vault_aws_secret_backend_role.admin.name
}