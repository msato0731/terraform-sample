# チーム固有の規約

このリポジトリ固有の必須事項・禁止パターン。公式の一般観点とは別に、必ず照合する。

## 必須

- すべての課金対象リソースに `Name` タグを付ける（`aws_vpc`, `aws_subnet`, `aws_security_group`, `aws_instance`, `aws_internet_gateway`, `aws_route_table` 等）
  - タグ欠落は **LOW**（複数箇所なら1件にまとめて指摘）
- `provider` の `region` はハードコードせず変数 or 既定に寄せる方針。直書きは **LOW**

## 禁止

- セキュリティグループの管理ポート（22/3389）を `0.0.0.0/0` で開けない → **HIGH**
  - 踏み台/SSM 経由を前提にする
- `terraform.tfstate` をリポジトリにコミットしない → 見つけたら **HIGH**
- AMI のハードコード禁止（環境差異の事故が起きるため）→ `data "aws_ami"` を使う → **LOW**

## 推奨

- EC2 は IMDSv2 必須（`http_tokens = "required"`）
- EBS / RDS は暗号化を明示する
