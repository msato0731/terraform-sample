# ecs-rolling-update

backend.tfvarsの書き換え。

```bash
cp backend.tfvars-sample backend.tfvars
vi backend.tfvars
tf init --backend-config="backend.tfvars"
```
