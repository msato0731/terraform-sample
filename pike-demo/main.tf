module "sqs" {
  source = "./module/sqs"
}

module "dynamodb" {
  source = "./module/dynamodb"
}