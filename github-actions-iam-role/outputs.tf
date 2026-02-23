output "oidc_provider_arn" {
  description = "ARN of the GitHub OIDC provider"
  value       = module.github_oidc.oidc_provider_arn
}

output "role_arn" {
  description = "ARN of the IAM role for GitHub Actions"
  value       = module.github_oidc.oidc_role
}

output "work_role_arn" {
  value = aws_iam_role.admin_role.arn
}
