locals {
  identity_store_id = tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]
  instance_arn      = tolist(data.aws_ssoadmin_instances.this.arns)[0]
  ################################################################################
  # Groups
  ################################################################################
  groups = {
    hoge_admin = {
      name        = "HogeAdministrator"
      description = "hoge service prd/stg:admin"
    }
    hoge_dev = {
      name        = "HogeDevelopperTeam"
      description = "hoge servide prd:read, stg:admin"
    }
    fuga_admin = {
      name        = "FugaAdministrator"
      description = "fuga service prd/stg:admin"
    }
    fuga_dev = {
      name        = "FugaDevelopperTeam"
      description = "fuga servide prd:read, stg:admin"
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
        "hoge_admin",
        "fuga_admin",
      ]
    }
    "jiro.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Jiro"
      }
      groups = [
        "hoge_dev",
        "fuga_dev"
      ]
    }
    "saburo.test@example.com" = {
      name = {
        family_name = "Test"
        given_name  = "Saburo"
      }
      groups = [
        "hoge_dev"
      ]
    }
  }
  ################################################################################
  # Membership
  ################################################################################

  # ユーザーとユーザーが属するグループの組み合わせを作成
  users_groups_combined = [
    for user, user_data in local.users : {
      for group in user_data.groups :
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

  ################################################################################
  # Account Assignments
  ################################################################################
  account_assignments = [
    # Hoge Service Production
    {
      account_id = var.account_ids.hoge_prd
      # aws_identitystore_groupのAttributeにgroup_nameがないため、localsから取得(aws provider 5.32.1時点)
      group          = "hoge_admin"
      permission_set = aws_ssoadmin_permission_set.administrator_access
    },
    {
      account_id     = var.account_ids.hoge_prd
      group          = "hoge_dev"
      permission_set = aws_ssoadmin_permission_set.readonly_access
    },
    # Hoge Service Staging
    {
      account_id     = var.account_ids.hoge_stg
      group          = "hoge_admin"
      permission_set = aws_ssoadmin_permission_set.administrator_access
    },
    {
      account_id     = var.account_ids.hoge_stg
      group          = "hoge_dev"
      permission_set = aws_ssoadmin_permission_set.administrator_access
    },
    # {
    #   group_name          = local.groups["fuga_admin"].name
    #   account_id             = var.account_ids.fuga_prd
    #   permission_set_name = aws_ssoadmin_permission_set.administrator_access.name
    # },
    # {
    #   group_name          = local.groups["fuga_admin"].name
    #   account_id             = var.account_ids.fuga_stg
    #   permission_set_name = aws_ssoadmin_permission_set.administrator_access.name
    # },
    # {
    #   group_name          = local.groups["fuga_dev"].name
    #   account_id             = var.account_ids.fuga_prd
    #   permission_set_name = aws_ssoadmin_permission_set.readonly_access.name
    # },
    # {
    #   group_name          = local.groups["fuga_dev"].name
    #   account_id             = var.account_ids.fuga_stg
    #   permission_set_name = aws_ssoadmin_permission_set.administrator_access.name
    # }
  ]

  # アカウントID-グループ名-PermissionSet名をキーに設定
  assignment_map = {
    for a in local.account_assignments :
    format("%v-%v-%v", a.account_id, local.groups[a.group].name, a.permission_set.name) => a
  }
}
