### AWS ###
variable "aws_region" {
  description = "The AWS region to contain resources."
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_route53_domain" {
  description = "The top level domain name used for redirects."
  type        = string
}

variable "aws_route53_zone_id" {
  description = "The premade route53 zone ID. The zone is created outside of here so that the domain config can be set up beforehand."
  type        = string
}

### GitHub ###
variable "gh_token" {
  description = "Github token with permissions to create and delete repos."
  type        = string
}

variable "gh_organization_name" {
  description = "The name of the GitHub organization."
  type        = string
}

### HCP ###
variable "hcp_project_id" {
  description = "The ID of the HCP project."
  type        = string
}

### HCP Terraform ###
variable "hcp_tf_aws_run_role_arn" {
  description = "The ARN of the AWS role used by HCP Terraform."
  type        = string
}

variable "hcp_tf_organization_name" {
  description = "The name of the HCP Terraform organization."
  type        = string
}

variable "hcp_tf_project_name" {
  description = "The name of the HCP Terraform project."
  type        = string
  default     = "test-hcp-waypoint"
}

variable "hcp_tf_team_name" {
  description = "The name of the HCP Terraform team."
  type        = string
  default     = "test-hcp-waypoint"
}

variable "hcp_tf_variables_set_name" {
  description = "The name of the HCP Terraform variables set."
  type        = string
  default     = "test-hcp-waypoint"
}

### Slack ###
variable "slack_hook_url" {
  description = "The URL of the Slack webhook."
  type        = string
}
