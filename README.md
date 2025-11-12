# terraform-sample

Terraform関連のブログ記事のサンプルコード置き場です。

## ブログ

| コード | ブログ |
| --- | --- |
| [hcp-vault-terraform](./hcp-vault-terraform/) | [HCP Vaultで一時的なAWSアクセスキーを発行してTerraformを実行してみる \| DevelopersIO](https://dev.classmethod.jp/articles/hcp-vault-temporary-aws-access-key-terraform/) |
| [tfc-ephemeral-workspace](./tfc-ephemeral-workspace/) | [\[アップデート\]Terraform Cloudにリソースの自動削除ができるephemeral workspaces機能が追加されました \| DevelopersIO](https://dev.classmethod.jp/articles/tfc-ephemeral-workspaces/) |
| [pluralith-demo](./pluralith-demo/) | [Terraform構成をビジュアライズできるツール Pluralithを使ってAWS構成図を自動作成してみる \| DevelopersIO](https://dev.classmethod.jp/articles/terraform-visualise-pluralith/) |
| [codepipeline-terraform](./codepipeline-terraform/) | [TerraformのCDパイプラインをCodeシリーズで作ってみる\(CI/CDアカウントにパイプラインを集約パターン\) \| DevelopersIO](https://dev.classmethod.jp/articles/tf-cd-pipeline-aggregation/) |
| [hcp-tf-dynamic-credentials-google](./hcp-tf-dynamic-credentials-google/) | [HCP TerraformとGoogle CloudのDynamic Credentials用のリソース作成とHCP Terraform Project適用までをTerraformでやってみた \| DevelopersIO](https://dev.classmethod.jp/articles/google-cloud-dynamic-credenitials-hcp-tf-apply-project/) |

## 実行方法

backend.tfvarsの書き換え。

```bash
cd <tfファイルがあるディレクトリ>
cp backend.tfvars-sample backend.tfvars
vi backend.tfvars
tf init --backend-config="backend.tfvars"
```

TFC使う場合。

```bash
export TF_CLOUD_ORGANIZATION="<Organization>"
export TF_CLOUD_PROJECT="<Project>"
export TF_WORKSPACE="<Workspace>"
```

[Terraform block configuration reference \| Terraform \| HashiCorp Developer](https://developer.hashicorp.com/terraform/language/terraform#environment-variables-for-the-cloud-block)
