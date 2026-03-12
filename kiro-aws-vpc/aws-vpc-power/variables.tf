variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "name" {
  description = "VPC名"
  type        = string
  default     = "my-vpc"
}

variable "cidr" {
  description = "VPCのCIDRブロック"
  type        = string
  default     = "10.0.0.0/16"
}

variable "tags" {
  description = "全リソースに付与するタグ"
  type        = map(string)
  default = {
    Terraform   = "true"
    Environment = "dev"
  }
}
