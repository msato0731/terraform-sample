# モジュール設計・style 観点

HashiCorp 公式 style guide（https://developer.hashicorp.com/terraform/language/style）に沿う。

## 値のハードコード

- AMI ID / アカウント ID / リージョン / CIDR を直接埋め込み → 変数化 or data source 化したい → **LOW**
  - 例: `ami = "ami-xxxx"` は `data "aws_ami"` か `var` に
- マジックナンバー（ポート番号以外）→ **LOW**

## 変数・出力

- `variable` に `type` が無い → **LOW**
- 重要な属性（id, arn, endpoint）の `output` が無く、他から参照できない → **LOW**
- `variable` の `description` 欠落 → 任意。**LOW**

## 命名・構成

- リソース名がリソース種別と重複（`resource "aws_vpc" "vpc"`）→ 慣例上 `main`/`this` 推奨 → **LOW**
- ファイル分割の慣例（`main.tf` / `variables.tf` / `outputs.tf` / `provider.tf`）から外れる → **LOW**

## モジュール化

- 同種リソースの繰り返しコピペ → `count`/`for_each` かモジュール化 → **LOW**
- 1ディレクトリに責務が混在（VPC とアプリが密結合）→ 分割検討 → **LOW**
