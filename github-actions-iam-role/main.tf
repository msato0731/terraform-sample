terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.27"
    }
  }
  backend "local" {
    # pathは実行時に指定
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "Terraform"
    }
  }
}

module "github_oidc" {
  source  = "terraform-module/github-oidc-provider/aws"
  version = "2.2.1"

  role_name                 = var.role_name
  role_description          = "Role for GitHub Actions OIDC"
  repositories              = var.repositories
  oidc_role_attach_policies = var.attach_policies
}

data "aws_iam_policy_document" "admin_assume_role_policy" {
  statement {
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [module.github_oidc.oidc_role]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "admin_role" {
  name               = "${var.role_name}-admin"
  description        = "Admin role assumable by GitHub Actions OIDC role"
  assume_role_policy = data.aws_iam_policy_document.admin_assume_role_policy.json
}

resource "aws_iam_role_policy_attachment" "admin_policy" {
  role       = aws_iam_role.admin_role.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
