provider "aws" {
  region = "ap-northeast-1"
}

data "aws_ssoadmin_instances" "this" {}
################################################################################
# Group
################################################################################

locals {
  aws_identitystore_group = {
    infra_team = {
      description = "prd/stg:admin"
    }
    developer_team = {
      description = "prd:read, stg:admin"
    }
  }
}

resource "aws_identitystore_group" "this" {
  for_each = local.aws_identitystore_group

  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = each.key
  description       = each.value.description
}

################################################################################
# User
################################################################################
locals {
  aws_identitystore_user = {
    "taro.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Taro"
      }
    }
    "jiro.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Jiro"
      }
    }
    "saburo.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Taro"
      }
    }
  }
}

resource "aws_identitystore_user" "test_taro" {
  for_each          = local.aws_identitystore_user
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  display_name      = join(" ", [each.value.name.given_name, each.value.name.family_name])
  user_name         = each.key

  name {
    family_name = each.value.name.family_name
    given_name  = each.value.name.given_name
  }
}
