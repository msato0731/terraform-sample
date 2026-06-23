# state 安全性・破壊/置換リスク観点

差分（HCL）から読み取れる範囲で照合する。plan の出力は今回のスキルでは扱わない。

## 破壊・置換を招く変更

- `name` / `name_prefix` の変更や、ForceNew 属性（多くの `*_id`、`availability_zone`、`subnet_id` 等）の変更
  - リソース再作成 → ダウンタイム/データ消失の可能性 → **MEDIUM**（DB/EBS など状態を持つものは **HIGH**）
- `count` / `for_each` のキー変更でインデックスがずれる → 既存リソースの破棄＋再作成 → **MEDIUM**

## lifecycle

- 状態を持つリソース（RDS, EBS, S3）で `prevent_destroy = true` が無い → 任意。明記すれば **LOW**
- `create_before_destroy` が必要な箇所（name_prefix を使う SG 等）で欠落 → **LOW**
- `ignore_changes` の過剰指定（管理外が増える）→ **LOW**

## state 操作の痕跡

- ハードコードされた既存リソース ID を import 前提で使っている形跡 → コメントで補足が無ければ **LOW**
