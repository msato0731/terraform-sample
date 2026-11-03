# PSC と VPC Peering で、内部ALB経由の Cloud Run が受け取る送信元IPを比べる

Private Service Connect（PSC）と VPC Network Peering で、内部アプリケーションロードバランサ（内部ALB）の後ろの Cloud Run に接続し、Cloud Run が受け取る `X-Forwarded-For` を比べる検証コードです。

| ディレクトリ | 内容 |
| --- | --- |
| [psc](./psc/) | 接続側 VPC の PSC エンドポイント → サービスアタッチメント → 内部ALB |
| [vpc-peering](./vpc-peering/) | 接続側 VPC と公開側 VPC を Peering でつなぎ、VM から内部ALBのIPへ直接 |

どちらも、接続側 VPC に外部IPなしの VM を置き、IAP 経由の SSH で `curl` を実行します。

## 実行方法

```bash
cd psc   # または vpc-peering
terraform init
terraform apply -var project_id=<PROJECT_ID>
```

apply 後の出力にある `ssh_command` で VM に入り、`curl_command_on_vm` を実行します。

確認が終わったら削除します。

```bash
terraform destroy -var project_id=<PROJECT_ID>
```
