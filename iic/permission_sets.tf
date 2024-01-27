resource "aws_ssoadmin_permission_set" "this" {
  for_each = local.permission_sets

  name         = each.value.name
  description  = each.value.description
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.permission_sets

  instance_arn       = local.instance_arn
  managed_policy_arn = each.value.managed_policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.key].arn
}
