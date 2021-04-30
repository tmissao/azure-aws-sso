data "aws_ssoadmin_instances" "sso" {}

resource "aws_ssoadmin_permission_set" "sets" {
  for_each     = var.aws_permissions_sets
  name         = each.value.name
  instance_arn = local.aws_sso.instance_arn
  session_duration = "P1M"
  tags         = var.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "attachment" {
  for_each           = local.aws_managed_policies_sets
  instance_arn       = aws_ssoadmin_permission_set.sets[each.key].instance_arn
  managed_policy_arn = each.value.policyArn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.key].arn
}

data "aws_iam_policy_document" "custom-policies" {
    for_each = local.aws_custom_policies_sets
    dynamic "statement" {
        for_each = each.value.customPolicy
        content {
            actions = statement.value["actions"]
            resources = statement.value["resources"]
        }
    }
}

resource "aws_ssoadmin_permission_set_inline_policy" "custom-policies-attachment" {
  for_each = local.aws_custom_policies_sets
  inline_policy      = data.aws_iam_policy_document.custom-policies[each.key].json
  instance_arn       = aws_ssoadmin_permission_set.sets[each.key].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[each.key].arn
}

# Since the user creation process does not happen on realtime, it is
# necessary to wait the Azure AD performs its synchonism with AWS. Otherwise
# an exception is raised on `data.aws_identitystore_user.aws_users` resource
resource "null_resource" "check-aws-users" {
  triggers = {
    USERS = join(",", local.users_group_roles_ids.*.user_principal_name)
  }
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/check-aws-user.sh"
    environment = {
      ACCESS_KEY        = var.aws_access_key_id
      SECRET_KEY        = var.aws_secret_access_key
      REGION            = var.aws_region
      IDENTITY_STORE_ID = local.aws_sso.identity_store_id
      USERNAMES         = join(",", local.users_group_roles_ids.*.user_principal_name)
    }
  }
}

data "aws_identitystore_user" "aws_users" {
  for_each          = azuread_user.users
  identity_store_id = local.aws_sso.identity_store_id
  filter {
    attribute_path  = "UserName"
    attribute_value = each.value.user_principal_name
  }
  depends_on = [null_resource.check-aws-users]
}

resource "aws_ssoadmin_account_assignment" "assigned" {
  for_each           = local.users_aws_roles_accounts
  instance_arn       = aws_ssoadmin_permission_set.sets[var.aws_accounts_permissions[each.value.aws_account_id][var.users[each.value.username].role]].instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.sets[var.aws_accounts_permissions[each.value.aws_account_id][var.users[each.value.username].role]].arn
  principal_id       = try(data.aws_identitystore_user.aws_users[each.value.username].user_id, azuread_user.users[each.value.username].object_id)
  principal_type     = "USER"
  target_id          = each.value.aws_account_id
  target_type        = "AWS_ACCOUNT"
}
