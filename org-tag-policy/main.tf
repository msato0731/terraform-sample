data "aws_caller_identity" "current" {}

resource "aws_organizations_policy" "example" {
  name    = "tag-policy-example"
  content = <<EOF
{
  "tags": {
    "Owner": {
      "tag_key": {
        "@@assign": "Owner"
      },
      "report_required_tag_for": {
        "@@assign": [
          "logs:log-group"
        ]
      }
    }
  }
}
EOF
  type    = "TAG_POLICY"
}

resource "aws_organizations_policy_attachment" "example" {
  policy_id = aws_organizations_policy.example.id
  target_id = data.aws_caller_identity.current.account_id
}

provider "aws" {
  tag_policy_compliance = "error"
}

resource "aws_cloudwatch_log_group" "example" {
  name = "required-tags-demo"
  tags = {
    Owner = "foo"
  }
}
