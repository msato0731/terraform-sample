locals {
  name_prefix                  = "codepipeline-terraform"
  terraform_execution_role_arn = "arn:aws:iam::${var.target_aws_account_id}:role/terraform-execution-role"
  codebuild_env_vars = {
    TERRAFORM_EXECUTION_ROLE_ARN = local.terraform_execution_role_arn
    CODE_SRC_DIR                 = "codepipeline-terraform/workload/infra"
    TF_VERSION                   = "1.5.4"
  }
}
