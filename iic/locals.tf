locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  ################################################################################
  # Groups
  ################################################################################
  groups = {
    infra_team = {
      name        = "InfraTeam"
      description = "prd/stg:admin"
    }
    dev_team = {
      name        = "DevTeam"
      description = "prd:read, stg:admin"
    }
  }
  ################################################################################
  # Users
  ################################################################################
  users = {
    "taro.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Taro"
      }
      groups = [
        "infra_team"
      ]
    }
    "jiro.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Jiro"
      }
      groups = [
        "dev_team"
      ]
    }
    "saburo.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Taro"
      }
      groups = [
        "dev_team",
        "infra_team"
      ]
    }
  }
  ################################################################################
  # Membership
  ################################################################################
  # user名とgroupだけを抽出
  # 例: "taro.test@example.com"   = ["infra_team"]
  extract_users_groups_only = {
    for user, user_data in local.users : user => user_data.groups
  }

  # ユーザーとユーザーが属するグループの組み合わせを作成
  users_groups_combined = [
    for user, groups in local.extract_users_groups_only : {
      for group in groups :
      "${user}_${group}" => {
        "user"  = user
        "group" = group
      }
    }
  ]

  # listで入っているため、使いやすいようにmapに変換する
  users_groups_membership = zipmap(
    flatten(
      [for item in local.users_groups_combined : keys(item)]
    ),
    flatten(
      [for item in local.users_groups_combined : values(item)]
    )
  )
}
