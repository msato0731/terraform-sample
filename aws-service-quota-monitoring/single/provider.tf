provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project    = "ServiceQuotaMonitoring"
      ManagedBy  = "Terraform"
      Repository = "terraform-sample/aws-service-quota-monitoring"
    }
  }
}
