resource "aws_ssoadmin_account_assignment" "this" {
  for_each = local.assignment_map

  instance_arn       = local.instance_arn
  permission_set_arn = each.value.permission_set.arn
  principal_id       = each.value.group_id
  principal_type     = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"
}
