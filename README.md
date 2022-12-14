# terraform-sample

backend.tfvarsの書き換え。

```bash
cd <tfファイルがあるディレクトリ>
cp backend.tfvars-sample backend.tfvars
vi backend.tfvars
tf init --backend-config="backend.tfvars"
```
