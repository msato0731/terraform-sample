# AWS Service Quota Monitoring - Multi-Account StackSet

このプロジェクトは、複数のAWSアカウントにサービスクォータ監視システムをTerraform経由でStackSetとしてデプロイするためのものです。

## アーキテクチャ

```bash
Trusted Advisor -> EventBridge -> Step Functions -> Slack Webhook
```

## プロジェクト構成

```bash
multi-stackset/
├── README.md                          # このファイル
├── main.tf                           # メインTerraform設定
├── terraform.tfvars                  # Terraform変数設定
├── files/                           # CloudFormationテンプレートとパラメータ
│   ├── service-quota-monitoring.yaml   # CloudFormationテンプレート
│   ├── parameters.json                 # パラメータファイル
│   └── parameters_sample.json          # パラメータサンプル
└── test/                            # テスト用ファイル
    └── all-events-put.json            # テスト用イベントデータ
```

## デプロイされるリソース

- **EventBridge Rule**: Trusted Advisorのアラートを監視
- **Step Functions State Machine**: Slack通知の実行
- **CloudWatch Log Group**: Step Functionsの実行ログ
- **IAM Roles**: EventBridgeとStep Functions用の実行ロール
- **EventBridge Connection**: Slack Webhook接続用

## 前提条件

### AWS要件

- Business または Enterprise サポートプラン（Trusted Advisor必須）
- StackSet用のIAM権限
- 複数アカウント/リージョンへのデプロイ権限

## デプロイ手順

### 1. Terraform変数の設定

`terraform.tfvars`を編集：

```hcl
# 必要な変数を設定
slack_webhook_url = "https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK"
```

### 2. Terraformでデプロイ

```bash
# 初期化
terraform init

# プランの確認
terraform plan

# デプロイ（自動承認）
terraform apply -auto-approve
```

### 3. デプロイの確認

AWS コンソールで以下を確認：
- CloudFormation StackSetsにStackSetが作成されている
- 対象アカウント/リージョンにスタックインスタンスが作成されている
- Step Functionsが正常に動作している

## テスト方法

### イベント送信テスト

テスト用イベントファイルを使用してSlack通知をテスト：

```bash
# カスタムイベントでテスト
aws events put-events \
    --entries file://test/all-events-put.json \
    --region us-east-1
```

**注意**:
- `custom.testing`ソースを使用するため、CloudFormationテンプレートで一時的にコメントインが必要です
- テストファイル内の`Amazon EC2 Reserved Instances Optimization`はステータスが`OK`のため通知されません（`ERROR`/`WARN`のみ対象）

## 運用

### 監視するサービスクォータの追加

`files/service-quota-monitoring.yaml`のEventBridge Ruleの`check-name`フィルターを編集：

### StackSetの更新

テンプレートまたはパラメータを変更後：

```bash
terraform apply -auto-approve
```

### StackSetの削除

```bash
terraform destroy -auto-approve
```

## セキュリティ

- IAM権限は最小権限の原則に従っています
- Slack Webhook URLは NoEcho パラメータで保護されています
- クロスアカウントアクセスはStackSetの標準的なセキュリティモデルを使用

## 制限事項

- Trusted Advisorのアラートは US East (N. Virginia) リージョンでのみ発生
- Business/Enterpriseサポートプランが必要
- 同時実行可能なStackSet操作は1つのみ
