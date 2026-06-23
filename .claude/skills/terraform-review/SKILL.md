---
name: terraform-review
description: Terraform（HCL）の変更をレビューする。PR やローカルの差分に対し、セキュリティ・state安全性・モジュール設計・チーム規約の観点で指摘を出す。「terraform をレビュー」「この HCL の変更を見て」「/terraform-review」などで使う。
---

# Terraform コードレビュー

Terraform の変更（PR 差分・ローカル差分）をレビューし、観点ごとに指摘をまとめる。
このスキルは**レビューの作業手順と出力形式**を定める。観点の詳細は `references/` に分割している。

HashiCorp 公式の style-guide / module 設計の考え方を土台にしているが、CI でそのまま動くよう
判断に必要な知識はこのスキル内に持たせている（外部プラグインへの依存なし）。

## レビュー対象の特定

1. 変更された `.tf` / `.tftest.hcl` を洗い出す
   - `git diff` が使えるなら: `git diff origin/<base>...HEAD -- '*.tf'`（base 不明なら `git diff main...HEAD`）
   - ローカル: `git diff` / `git diff --staged`
   - **git が使えない CI 等では**、PR の変更ファイル一覧（コンテキストで渡される）から対象 `.tf` を特定し、`Read` で直接読む
2. 追加・変更された行を中心に読む。削除行は「消したことで壊れる依存」だけ見る
3. 変更ファイルが参照する周辺リソース（同ディレクトリの既存 `.tf`）も必要に応じて読む

設定の生成・大規模な書き換えはしない。**指摘だけ**を返す。

## 観点（references を読んでから当てる）

- `references/security.md` — セキュリティ（公開範囲・暗号化・IMDS・IAM 等）
- `references/state-and-lifecycle.md` — state 安全性・破壊/置換リスク・lifecycle
- `references/module-and-style.md` — モジュール設計・命名・vari/output・style 規約
- `references/team-conventions.md` — このリポジトリ固有の禁止パターンと必須事項

各 reference の項目を、変更差分に対して機械的に照合する。該当しない観点は黙って飛ばす。

## 重大度

| 重大度 | 基準 |
|---|---|
| HIGH | 本番で実害（情報漏えい・全公開・データ消失・権限過剰）に直結する |
| MEDIUM | セキュリティ/運用のベストプラクティス違反。事故時の影響が大きい |
| LOW | 規約・可読性・保守性。動作はするが直したい |

迷ったら一段下げる。憶測で HIGH を付けない。差分から読み取れる事実だけで判断する。

## 出力形式

最初に1行サマリ（HIGH/MEDIUM/LOW の件数）。続けて重大度の高い順に列挙する。

```
## Terraform レビュー結果

HIGH: 1 / MEDIUM: 2 / LOW: 2

### [HIGH] <一言タイトル>
- 対象: `path/to/file.tf` の `resource "aws_..." "name"`
- 指摘: 何が問題か（事実ベースで1〜2文）
- 提案: どう直すか（可能なら HCL の修正例を diff で）
```

- 指摘ゼロなら「指摘なし」と明記する。無理に粗探ししない
- 修正例は最小限。変更行だけ示す
- 1つの指摘は3〜5行に収める。冗長な前置きを書かない
