provider "aws" {
  // See https://registry.terraform.io/providers/hashicorp/aws/latest/docs#authentication-and-configuration
  // for options on how to configure this provider. The following parameters or environment
  // variables are typically used.

  // Parameters:
  // access_key = ""
  // secret_key = ""
  // region     = ""

  // Environment variables:
  // AWS_ACCESS_KEY_ID
  // AWS_SECRET_ACCESS_KEY
  // AWS_REGION
}

variable "external_id" {
  type        = string
  description = "External ID to securely delegate access to HCP Vault Secrets"
  sensitive   = true
}

resource "aws_iam_role" "hashicorp_vault_secrets_role" {
  name = "HCPVaultSecrets"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::879554817125:role/HCPVaultSecrets_Sync"
        }
        Condition = {
          StringEquals = {
            "sts:ExternalId" = var.external_id
          }
        }
      }
    ]
  })

  inline_policy {
    name   = "HCPVaultSecrets"
    policy = data.aws_iam_policy_document.hashicorp_vault_secrets_policy.json
  }
}

data "aws_iam_policy_document" "hashicorp_vault_secrets_policy" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:DescribeSecret",
      "secretsmanager:GetSecretValue",
      "secretsmanager:CreateSecret",
      "secretsmanager:PutSecretValue",
      "secretsmanager:UpdateSecret",
      "secretsmanager:UpdateSecretVersionStage",
      "secretsmanager:DeleteSecret",
      "secretsmanager:RestoreSecret",
      "secretsmanager:TagResource",
      "secretsmanager:UntagResource"
    ]
    resources = ["*"]
  }
}

output "role_arn" {
  description = "Role ARN to configure the AWS Secrets Manager Integration"
  value       = aws_iam_role.hashicorp_vault_secrets_role.arn
}
