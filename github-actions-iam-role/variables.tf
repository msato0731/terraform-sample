variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "role_name" {
  description = "Name of the IAM role for GitHub Actions"
  type        = string
  default     = "github-actions-role"
}

variable "repositories" {
  description = "List of GitHub organization/repository names (e.g., ['owner/repo', 'owner/repo:ref:refs/heads/main'])"
  type        = list(string)
}

variable "attach_policies" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}
