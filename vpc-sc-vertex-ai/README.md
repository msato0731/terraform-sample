# VPC Service Controls × Vertex AI 検証用 Terraform

EC2からVertex AI APIを呼び出し、VPC Service Controls（IP制限）が有効かどうかを検証するための環境です。

## 構成

```text
vpc-sc-vertex-ai/
├── aws/   # EC2 + NAT Gateway（固定EIPで外部IPを固定）
└── google-cloud/   # Access Policy / Access Level / Service Perimeter
```

## 事前準備（ローカル）

### AWS Session Manager プラグインのインストール

SSM Session ManagerでEC2に接続するために必要です。

```bash
# macOS (Apple Silicon)
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac_arm64/sessionmanager-bundle.zip" -o sessionmanager-bundle.zip
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
```

その他のOSは[公式ドキュメント](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)を参照してください。

## 事前準備（GCP）

### GCP APIの有効化

```bash
gcloud services enable \
  iam.googleapis.com \
  iamcredentials.googleapis.com \
  accesscontextmanager.googleapis.com \
  aiplatform.googleapis.com \
  sts.googleapis.com \
  cloudresourcemanager.googleapis.com \
  --project=<your-project-id>
```

### ADCの設定

TerraformはADC（Application Default Credentials）を使ってGCPリソースを作成します。

```bash
gcloud auth application-default login
gcloud auth application-default set-quota-project <your-project-id>
```

## 適用手順

### Step 1: AWS（EC2 + NAT Gateway）を作成

```bash
cd aws
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集して適切な値を設定

terraform init
terraform apply
```

**Outputを控える：**

```bash
terraform output
```

- `nat_gateway_ip` → GCPのIP許可リストに設定
- `ec2_instance_id` → SSM接続に使用
- `ec2_iam_role_arn` → GCP Workload Identity Federationに使用

### Step 2: GCP（VPC Service Controls）を設定

```bash
cd ../google-cloud
cp terraform.tfvars.example terraform.tfvars
# terraform.tfvars を編集してStep 1のOutputを設定
```

`terraform.tfvars` の設定例：

```hcl
org_id            = "123456789012"
project_id        = "your-project-id"
project_number    = "123456789012"
aws_account_id    = "123456789012"
ec2_iam_role_name = "vpc-sc-test-ec2-role"
allowed_cidrs     = ["x.x.x.x/32"]  # nat_gateway_ip の値
```

```bash
terraform init
terraform apply
```

### Step 3: EC2上での検証

```bash
EC2_INSTANCE_ID=$(cd ../aws && terraform output -raw ec2_instance_id)
```

#### ① SSM Session Managerで接続

```bash
aws ssm start-session --target "$EC2_INSTANCE_ID"
```

接続するとデフォルトは `ssm-user` でログインされます。`ec2-user` にスイッチしてください。

```bash
sudo su - ec2-user
```

以降はEC2上で実行します。

#### ② gcloud CLIのインストール

```bash
sudo tee /etc/yum.repos.d/google-cloud-sdk.repo << 'REPO'
[google-cloud-cli]
name=Google Cloud CLI
baseurl=https://packages.cloud.google.com/yum/repos/cloud-sdk-el9-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=0
gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
REPO
sudo dnf install -y google-cloud-cli
```

#### ③ Python環境のセットアップ

```bash
sudo dnf install -y python3.14
python3.14 -m venv ~/vertex-ai-test
~/vertex-ai-test/bin/pip install google-genai google-auth
```

#### ④ Pythonスクリプトの作成

```bash
cat > /home/ec2-user/vertex_ai_client.py << 'EOF'
import json
import os

from google import genai
from google.auth import aws
from google.auth.transport.requests import Request


def initialize_credentials():
    credentials_file = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
    project_id = os.environ.get("GCP_PROJECT_ID")
    location = os.environ.get("GCP_LOCATION", "us-central1")

    with open(credentials_file, "r") as f:
        credentials_info = json.load(f)

    credentials = aws.Credentials.from_info(
        credentials_info,
        scopes=["https://www.googleapis.com/auth/cloud-platform"],
    )
    credentials.refresh(Request())

    return credentials, project_id, location


def call_gemini(credentials, project_id, location, prompt):
    client = genai.Client(
        vertexai=True,
        project=project_id,
        location=location,
        credentials=credentials,
    )
    response = client.models.generate_content(
        model="gemini-2.5-flash",
        contents=prompt,
    )
    return response.text


def main():
    credentials, project_id, location = initialize_credentials()
    prompt = "Google Cloudとは何ですか？簡潔に説明してください。"
    result = call_gemini(credentials, project_id, location, prompt)
    print(f"Generated text:\n{result}")


if __name__ == "__main__":
    main()
EOF
```

#### ⑤ credential configファイルの生成

```bash
gcloud iam workload-identity-pools create-cred-config \
  <workload_identity_pool_name>/providers/aws-provider \
  --service-account=<service_account_email> \
  --aws \
  --enable-imdsv2 \
  --output-file=/tmp/gcp_credential_config.json
```

#### ⑥ 環境変数を設定してGeminiを呼び出す

```bash
export AWS_REGION=<aws_region>
export GOOGLE_APPLICATION_CREDENTIALS=/tmp/gcp_credential_config.json
export GCP_PROJECT_ID=<project_id>
export GCP_LOCATION=us-central1

source ~/vertex-ai-test/bin/activate
python vertex_ai_client.py
```

### Step 4: 拒否テスト

許可IPをダミーに差し替えて、EC2からのアクセスが拒否されることを確認します。

```bash
# ローカルで実行（google-cloud/ディレクトリで）
POLICY_ID=$(terraform output -raw access_policy_name)
```

許可IPをダミーに変更：

```bash
gcloud access-context-manager levels update <prefix>_allow_ec2_ip \
  --basic-level-spec=../deny-test.yaml \
  --policy=${POLICY_ID}
```

EC2から`python vertex_ai_client.py`を実行し、アクセスが拒否されることを確認します。

確認後、Terraformで許可IPを復元：

```bash
terraform apply
```

## 検証を一時停止する場合

高額なリソース（NAT Gateway・EC2）だけを削除して、後から再開できます。EIPは残しておくことでIPアドレスを固定できます。

```bash
cd aws

# EC2インスタンスを削除
terraform destroy -target=aws_instance.test

# NAT Gatewayを削除（EIPは残す）
terraform destroy -target=aws_nat_gateway.nat
```

再開時は `terraform apply` で再作成できます。ただし、NAT GatewayのIPが変わるため、GCP側の `allowed_cidrs` を更新して `terraform apply` し直す必要があります。

## 注意事項

- `terraform.tfvars` はGitignore対象です。コミットしないよう注意してください
- NAT GatewayはEC2が停止していても課金されます。検証後は `terraform destroy` で削除してください
