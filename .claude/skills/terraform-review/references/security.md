# セキュリティ観点

変更差分に対して以下を照合する。該当する変更が無ければ飛ばす。

## ネットワーク公開範囲

- セキュリティグループ / NACL の `ingress` で `cidr_blocks = ["0.0.0.0/0"]`
  - 管理ポート（22/SSH, 3389/RDP）の全開放は **HIGH**
  - DB ポート（3306/5432/6379 等）の全開放は **HIGH**
  - 80/443 の全開放は用途次第。公開 Web なら許容、内部向けなら **MEDIUM**
- `map_public_ip_on_launch = true` のサブネットに置く機密リソースは **MEDIUM**

## 暗号化

- `aws_instance` / `aws_ebs_volume` の `root_block_device` / `ebs_block_device` に `encrypted = true` が無い → **MEDIUM**
- `aws_s3_bucket` でサーバーサイド暗号化リソースが無い → **MEDIUM**
- `aws_db_instance` / `aws_rds_cluster` の `storage_encrypted = true` が無い → **MEDIUM**

## EC2 メタデータ（IMDS）

- `aws_instance` に `metadata_options { http_tokens = "required" }` が無い → IMDSv2 未強制 → **MEDIUM**

## IAM / 認証情報

- `iam_policy` 等で `Action = "*"` や `Resource = "*"` の広すぎる権限 → **HIGH/MEDIUM**
- アクセスキー・シークレット・パスワードのハードコード → **HIGH**

## 公開設定

- `aws_s3_bucket_public_access_block` が無い / `block_public_acls = false` → **MEDIUM**
- `publicly_accessible = true`（RDS 等） → **HIGH**
