# terraform-sample

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