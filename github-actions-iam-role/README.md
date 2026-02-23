# GitHub Actions IAM Role (OIDC)

GitHub ActionsからAWSにOIDC認証でアクセスするためのIAMロールを作成します。

## 使用方法

### 基本的な使用方法

```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集
terraform init
terraform plan
terraform apply
```

### 複数AWSアカウント対応

複数のAWSアカウントでローカルstateファイルを分離して管理する場合：

```bash
# アカウントA用（既存のstateファイルをリネーム）
terraform init -reconfigure -backend-config=env/backend-account-a.hcl

# アカウントB用
terraform init -reconfigure -backend-config=env/backend-account-b.hcl
```

## GitHub Actions での使用例

```yaml
jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      id-token: write
      contents: read
    steps:
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/github-actions-role
          aws-region: ap-northeast-1
```

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region | AWS region | string | ap-northeast-1 |
| role_name | IAMロール名 | string | github-actions-role |
| repositories | 許可するリポジトリのリスト | list(string) | - |
| attach_policies | アタッチするIAMポリシーARNのリスト | list(string) | [] |

## Outputs

| Name | Description |
|------|-------------|
| oidc_provider_arn | GitHub OIDC プロバイダーの ARN |
| role_arn | GitHub Actions 用 IAM ロールの ARN |
