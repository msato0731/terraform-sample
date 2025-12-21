# IAM Identity Center (Account Instance)

AWS IAM Identity Center（旧AWS SSO）をアカウントインスタンスとして有効化し、ユーザーを作成するTerraformコード。

## プロバイダー構成

- `awscc` - IAM Identity Center インスタンスの有効化
- `aws` - Identity Store ユーザーの作成

## 前提条件

- AWS Organizations を使用していない単一アカウント環境
- IAM Identity Center がまだ有効化されていないこと

## 使用方法

```bash
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集
terraform init
terraform plan
terraform apply
```

## 注意事項

- IAM Identity Center は1アカウントにつき1インスタンスのみ作成可能
- 一度有効化すると、削除には AWS サポートへの連絡が必要な場合あり
- Organizations 使用時は、管理アカウントで組織インスタンスとして有効化を推奨

## Inputs

| Name | Description | Type | Default |
|------|-------------|------|---------|
| region | AWS region | string | ap-northeast-1 |
| instance_name | Identity Center インスタンス名 | string | identity-center |
| user_given_name | ユーザーの名 | string | - |
| user_family_name | ユーザーの姓 | string | - |
| user_email | ユーザーのメールアドレス | string | - |
