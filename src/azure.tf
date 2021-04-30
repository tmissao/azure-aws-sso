resource "azuread_group" "role_groups" {
  for_each     = var.role_groups
  display_name = each.value.name
}

resource "azuread_group" "squad_groups" {
  for_each     = var.squad_groups
  display_name = each.value.name
}

resource "azuread_user" "users" {
  for_each              = var.users
  user_principal_name   = "${each.key}@${var.tenant_domain}"
  given_name            = each.value.firstName
  surname               = each.value.lastName
  display_name          = "${each.value.firstName} ${each.value.lastName}"
  password              = var.password
  force_password_change = true
}

resource "azuread_group_member" "assigned_role_groups" {
  for_each         = local.users_group_roles
  group_object_id  = each.value.group_object_id
  member_object_id = each.value.user_object_id
}

resource "azuread_group_member" "assigned_squad_groups" {
  for_each         = local.users_group_squad
  group_object_id  = each.value.group_object_id
  member_object_id = each.value.user_object_id
}

# Currently there is not a resource to add an Azure AD user on an AD application.
# Therefore its association is created using the AZ Rest and a bash script.
resource "null_resource" "allow-user-to-ssh" {
  triggers = {
    USER_IDS = join(",", local.users_group_roles_ids.*.user_object_id)
  }
  provisioner "local-exec" {
    command = "/bin/bash ./scripts/allow-user-to-sso.sh"
    environment = {
      CLIENT_ID     = var.arm_client_id
      CLIENT_SECRET = var.arm_client_secret
      TENANT_ID     = var.arm_tenant_id
      USER_IDS      = join(",", local.users_group_roles_ids.*.user_object_id)
      APP_ROLE_ID   = var.application_single_sign_on_role_id
      SP_OBJECT_ID  = var.application_single_sign_on_resource_id
    }
  }
}
