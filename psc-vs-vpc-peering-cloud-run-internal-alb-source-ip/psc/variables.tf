variable "project_id" {
  description = "Google Cloud プロジェクト ID"
  type        = string
}

variable "region" {
  type    = string
  default = "asia-northeast1"
}

variable "zone" {
  type    = string
  default = "asia-northeast1-a"
}

variable "name_prefix" {
  type    = string
  default = "psc-lab"
}

variable "psc_nat_cidr" {
  description = "PSC の NAT 用サブネット。IP の消費を観察しやすいよう小さくしている"
  type        = string
  default     = "10.20.2.0/28"
}
