provider "aws" {
  region = "ap-northeast-1"
}

terraform {
  cloud {
    workspaces {
      name = "sato-epehemeral-workspace-test"
    }
  }
}

resource "aws_sqs_queue" "sqs_queue" {
  name = "sato-epehemeral-workspace-test"
}
