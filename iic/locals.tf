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

  # ユーザーがブロックごとに分かれているため、ユーザーとグループの組み合わせを1つのブロックにまとめる
  users_groups_membership = zipmap(
    flatten(
      [for item in local.users_groups_combined : keys(item)]
    ),
    flatten(
      [for item in local.users_groups_combined : values(item)]
    )
  )

  ########################
  # Permissions
  ########################
  permission_sets = {
    "admin" = {
      name               = "AdministratorAccess"
      description        = "Provides full access to AWS services and resources."
      managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
    },
    "read_only" = {
      name               = "ReadOnlyAccess"
      description        = "Provides read-only access to AWS services and resources."
      managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
    }
  }

  ################################################################################
  # Account Assignments
  ################################################################################
  account_assignments = [
    # Hoge Service Production
    {
      account_id     = var.account_ids.hoge_prd
      group          = "hoge_admin"
      permission_set = "admin"
    },
    {
      account_id     = var.account_ids.hoge_prd
      group          = "hoge_dev"
      permission_set = "read_only"
    },
    # Hoge Service Staging
    {
      account_id     = var.account_ids.hoge_stg
      group          = "hoge_admin"
      permission_set = "admin"
    },
    {
      account_id     = var.account_ids.hoge_stg
      group          = "hoge_dev"
      permission_set = "admin"
    },
    # Fuga Service Production
    # {
    #   account_id     = var.account_ids.fuga_prd
    #   group          = "fuga_admin"
    #   permission_set = "admin"
    # },
    # {
    #   account_id     = var.account_ids.fuga_prd
    #   group          = "fuga_dev"
    #   permission_set = "read_only"
    # },
    # # Fuga Service Staging
    # {
    #   account_id     = var.account_ids.fuga_stg
    #   group          = "fuga_admin"
    #   permission_set = "admin"
    # },
    # {
    #   account_id     = var.account_ids.fuga_stg
    #   group          = "fuga_dev"
    #   permission_set = "admin"
    # }
  ]

  # アカウントID-グループ名-PermissionSet名をキーに設定
  assignment_map = {
    for a in local.account_assignments :
    format("%v-%v-%v", a.account_id, local.groups[a.group].name, local.permission_sets[a.permission_set].name) => a
  }
}
