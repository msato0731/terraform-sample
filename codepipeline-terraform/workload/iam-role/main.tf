provider "aws" {
  region = "ap-northeast-1"
}

# Principalにはワイルドーカードが使えない・引受元のRoleが存在している必要があるため、先にPipelineを作成する必要がある
# https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/reference_policies_elements_principal.html

resource "aws_iam_role" "terraform" {
  name = "terraform-execution-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "${var.pipeline_role_arn}"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "administorator_access" {
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  role       = aws_iam_role.terraform.name
}
