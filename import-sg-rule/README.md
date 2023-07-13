#　質問

Terraformで作成したセキュリティグループに、手動でルールを追加した。

その後Terraformで手動で作成したルールを追加した。

その際に、`terraform plan`で手動で作成したルールが削除されてTerraformで作成したルールが追加された。

想定する動作としては、Terraform側にルールを追加したため`terraform plan`時に差分が発生しない。

想定した動作になっていない理由はどういったものか？

# 回答

結論: tfstateに追加リソースの情報がなかったため、差分が発生しました。事前にimportを行うことで、差分発生させずに変更することが可能です。

Terraformでは、インフラ状態を管理するファイル(以下、tfstate)があります。

このファイルはTerraformリソースとTerraformのマッピングを行っています。

例えば、以下のtfファイルを作成します。

```
resource "aws_security_group_rule" "example" {
  type              = "ingress"
  from_port         = 0
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.1.0/24"]
  security_group_id = aws_security_group.allow_tls.id
}
```

tfstateに以下の記述が追加されます。

```
      "type": "aws_security_group_rule",
      "name": "example",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 2,
          "attributes": {
            "cidr_blocks": [
              "10.0.1.0/24"
            ],
            "description": null,
            "from_port": 0,
            "id": "sgrule-3131487798",
            # 省略
```

[State \| Terraform \| HashiCorp Developer](https://developer.hashicorp.com/terraform/language/state/purpose)

tfstateへの書き込みは、`apply`や`import`の際に発生します。

そのため、`plan`時には以下の状態でした。

- tfstate: セキュリティグループルールが存在しない
- terraformコード: セキュリティグループルールが存在する
- 実際のインフラ: セキュリティグループルールが存在する

tfstateにセキュリティグループルールが無いため、Terraformはtfstateと実態を合わせるためにセキュリティグループルールを削除します。

その後、terraformコード上にはルールがあるため、tfstateにルールを追加してリソースを作成しました。

## importを行って差分を発生させずに変更を行う

Importを行うことで、

- [aws\_security\_group \| Resources \| hashicorp/aws \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/3.42.0/docs/resources/security_group)
- [aws\_security\_group\_rule \| Resources \| hashicorp/aws \| Terraform Registry](https://registry.terraform.io/providers/hashicorp/aws/3.42.0/docs/resources/security_group_rule)