variable "aws_region" {
  description = "The AWS region to deploy the IAM role to"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_ou_id" {
  description = "The id of the OU to deploy the IAM role to"
  type        = string
}

variable "hcp_tf_organization_name" {
  description = "The name of the HCP Terraform organization"
  type        = string
}

variable "hcp_tf_iam_role_name" {
  description = "The name of the IAM role to create"
  type        = string
  default     = "hcp-tf-role"
}
