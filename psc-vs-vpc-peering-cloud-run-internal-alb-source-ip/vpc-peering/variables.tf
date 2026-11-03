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

variable "domain_name" {
  description = "VM が名前解決するドメイン（VM の /etc/hosts に登録）"
  type        = string
  default     = "app.lab.example.com"
}

variable "name_prefix" {
  type    = string
  default = "peer-lab"
}
