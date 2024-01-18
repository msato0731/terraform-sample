# terraform-sample

Terraform関連のブログ記事のサンプルコード置き場です。

## ブログ

| コード | ブログ |
| --- | --- |
| [hcp-vault-terraform](./hcp-vault-terraform/) | [HCP Vaultで一時的なAWSアクセスキーを発行してTerraformを実行してみる \| DevelopersIO](https://dev.classmethod.jp/articles/hcp-vault-temporary-aws-access-key-terraform/) |
| [tfc-ephemeral-workspace](./tfc-ephemeral-workspace/) | [\[アップデート\]Terraform Cloudにリソースの自動削除ができるephemeral workspaces機能が追加されました \| DevelopersIO](https://dev.classmethod.jp/articles/tfc-ephemeral-workspaces/) |
| [pluralith-demo](./pluralith-demo/) | [Terraform構成をビジュアライズできるツール Pluralithを使ってAWS構成図を自動作成してみる \| DevelopersIO](https://dev.classmethod.jp/articles/terraform-visualise-pluralith/) |
| [codepipeline-terraform](./codepipeline-terraform/) | [TerraformのCDパイプラインをCodeシリーズで作ってみる\(CI/CDアカウントにパイプラインを集約パターン\) \| DevelopersIO](https://dev.classmethod.jp/articles/tf-cd-pipeline-aggregation/) |


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
export TF_CLOUD_ORGANIZATION="<Org名>"
```