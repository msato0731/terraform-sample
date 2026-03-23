variable "prefix" {
  description = "組織レベルリソースの名前プレフィックス（複数人が同一組織を使う場合に識別するため）"
  type        = string
  default     = "myname"
}

variable "org_id" {
  description = "GCP組織ID"
  type        = string
}

variable "project_id" {
  description = "GCPプロジェクトID"
  type        = string
}

variable "project_number" {
  description = "GCPプロジェクト番号"
  type        = string
}

variable "aws_account_id" {
  description = "AWSアカウントID（Workload Identity Federation用）"
  type        = string
}

variable "ec2_iam_role_name" {
  description = "EC2のIAMロール名（Workload Identity Federation用）"
  type        = string
}

variable "allowed_cidrs" {
  description = "Vertex AIへのアクセスを許可するCIDRリスト（EC2のNAT GW EIPを含む）"
  type        = list(string)
}
