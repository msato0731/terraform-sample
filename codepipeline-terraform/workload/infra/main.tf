terraform {
  backend "s3" {
    bucket         = "terraform-state-20230808" # 置き換えが必要
    key            = "codepipeline-terraform-infra.tfstate"
    region         = "ap-northeast-1"
    encrypt        = true
    dynamodb_table = "terraform-state-20230808" # 置き換えが必要
  }
}

resource "aws_sqs_queue" "example" {
  name = "example-queue"
}

# パイプラインテスト用
# resource "aws_sqs_queue" "example2" {
#   name = "example-queue2"
# }
