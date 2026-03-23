variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "vpc-sc-test"
}

variable "az" {
  description = "アベイラビリティーゾーン"
  type        = string
  default     = "ap-northeast-1a"
}
