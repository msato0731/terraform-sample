resource "aws_ssoadmin_permission_set" "administrator_access" {
  name         = "AdministratorAccess"
  description  = "Provides full access to AWS services and resources."
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "administrator_access" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
  permission_set_arn = aws_ssoadmin_permission_set.administrator_access.arn
}

resource "aws_ssoadmin_permission_set" "readonly_access" {
  name         = "ReadOnlyAccess"
  description  = "Provides read-only access to AWS services and resources."
  instance_arn = local.instance_arn
}

resource "aws_ssoadmin_managed_policy_attachment" "readonly_access" {
  instance_arn       = local.instance_arn
  managed_policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
  permission_set_arn = aws_ssoadmin_permission_set.readonly_access.arn
}
