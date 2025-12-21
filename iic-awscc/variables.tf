variable "region" {
  description = "AWS region to deploy IAM Identity Center"
  type        = string
  default     = "ap-northeast-1"
}

variable "instance_name" {
  description = "Name for the IAM Identity Center instance"
  type        = string
  default     = "identity-center"
}

variable "user_given_name" {
  description = "Given name (first name) of the user"
  type        = string
}

variable "user_family_name" {
  description = "Family name (last name) of the user"
  type        = string
}

variable "user_email" {
  description = "Email address of the user"
  type        = string
}
