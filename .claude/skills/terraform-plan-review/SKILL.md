---
name: terraform-plan-review
description: terraform plan の出力（JSON）をレビューする。HCL を静的に読むのではなく、provider に問い合わせた実際の差分（plan）を見て、replace（再作成）・delete（削除）・想定外の更新など「適用したら何が起きるか」のリスクを指摘する。「plan をレビュー」「この plan.json を見て」「/terraform-plan-review」などで使う。
---

# Terraform plan レビュー

`terraform plan` の結果（`terraform show -json` の出力）をレビューし、適用時のリスクを指摘する。
コードレビュー（HCL を静的に読む）とは別物で、**provider が返した実際の差分**を対象にする。
コードを読むだけでは気づきにくい replace（破棄→再作成）・delete を最優先で拾う。

このスキルは CI でそのまま動くよう、判断に必要な知識をスキル内に持たせている（外部プラグイン非依存）。

## レビュー対象の特定

1. 引数で渡された plan JSON ファイル（例 `plan.json`）を `Read` する
   - 大きくて読みきれない場合は `Bash(jq '.resource_changes' plan.json)` で差分配列だけに絞る
2. `.resource_changes[]` を走査する。各要素の `.address` と `.change.actions` を見る

## アクション分類（plan レビューの肝）

`.change.actions` の配列でアクションを判定する。

| `actions` | 意味 |
|---|---|
| `["no-op"]` | 変更なし（無視） |
| `["create"]` | 新規作成 |
| `["update"]` | インプレース更新 |
| `["delete"]` | 削除 |
| `["delete","create"]` | replace（破棄→再作成） |
| `["create","delete"]` | replace（create_before_destroy。新規作成→旧削除） |

**replace と delete を最優先で拾う**。create / update / no-op は件数だけ数える。

replace の理由は `.change.replace_paths`（再作成を招いた属性パス）で確認できる。指摘に添えると親切。

## 重大度

| 重大度 | 基準 |
|---|---|
| HIGH | 状態を持つリソース（RDS / EBS / EC2 のルートボリューム / S3 / DynamoDB 等）の delete・replace（データ消失）。PR の意図に無い想定外の delete |
| MEDIUM | ステートレスなリソースの replace（ダウンタイムのみ）。多数リソースへの波及 |
| LOW | 影響の小さい update など |

迷ったら一段下げる。憶測で HIGH を付けない。plan から読み取れる事実だけで判断する。
1つの変更が N 個のリソースに波及する場合は件数を明示する。

## センシティブ値の扱い（必須・public リポジトリ前提）

plan JSON には Terraform が `sensitive` と印を付けない値（アカウントID・ARN・各属性の before/after）も載る。
**これらの生値をコメントに出さない。** 出力してよいのは次だけ:

- リソースアドレス（例 `aws_instance.web`）
- アクション（replace / delete など）
- replace を招いた属性の**名前**（例 `ami` が変わった）。値そのものは出さない
- なぜ危険か・確認すべきこと（一般的な説明）

`before` / `after` / `sensitive_values` / `after_unknown` の中身は引用しない。

## 出力形式

最初に1行サマリ（create / update / delete / **replace** の件数）。続けて replace / delete を重大度の高い順に列挙する。

```
## Terraform plan レビュー結果

create: 0 / update: 0 / delete: 0 / replace: 1

### [HIGH] aws_instance.web が replace（破棄→再作成）される
- アクション: replace（delete → create）
- 要因: `ami` 属性の変更（ForceNew）
- リスク: インスタンス再作成でルート EBS のデータが失われ、ダウンタイムが発生する
- 確認: 意図した AMI 更新か。データ移行・スナップショットが必要でないか
```

- replace / delete がゼロなら「破壊的変更なし（create/update のみ）」と明記する。無理に粗探ししない
- 1つの指摘は3〜5行に収める。冗長な前置きを書かない
