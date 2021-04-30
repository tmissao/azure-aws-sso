locals {
  # List containing AD Users IDS
  users_group_roles_ids = [
    for k, v in azuread_user.users : {
      user_principal_name = v.user_principal_name
      user_object_id      = v.object_id
    }
  ]
  # Builds a link between role groups and users created on Azure ID
  # The 'if' exists because of deleting process, otherwise an error is raised
  users_group_roles = {
    for k, v in azuread_user.users : k => {
      user_principal_name = v.user_principal_name
      user_object_id      = v.object_id
      group_name          = azuread_group.role_groups[var.users[k].role].display_name
      group_object_id     = azuread_group.role_groups[var.users[k].role].object_id
    }
    if lookup(var.users, k, null) != null
  }
  # Builds a link between squad groups and users created on Azure AD
  # The 'if' exists because of the deleting process and also, because an user
  # could not be in a squad.
  users_group_squad = {
    for k, v in azuread_user.users : k => {
      user_principal_name = v.user_principal_name
      user_object_id      = v.object_id
      group_name          = azuread_group.squad_groups[var.users[k].squad].display_name
      group_object_id     = azuread_group.squad_groups[var.users[k].squad].object_id
    }
    if lookup(lookup(var.users, k, tomap({ squad : null })), "squad", null) != null
  }
  # Performs a Cartesian Product ( X * Y ) between AWS Accounts and Users
  # since it is necessary to create a link between an user and its permissions in the AWS Accounts
  # The key is the join between AWS Account ID and the username
  users_aws_roles_accounts = {
    for v in setproduct(keys(var.aws_accounts_permissions), keys(var.users)) : format("%s-%s", v[0], v[1]) => {
      aws_account_id = v[0]
      username       = v[1]
    }
  }
  # Although AWS just allows one SSO entity, the terraform resource returns a list. Thus,
  # the variable below was created to become its use more fluently
  aws_sso = {
    instance_arn      = tolist(data.aws_ssoadmin_instances.sso.arns)[0]
    identity_store_id = tolist(data.aws_ssoadmin_instances.sso.identity_store_ids)[0]
  }
 # Creates a new map segregating all aws managed policies
  aws_managed_policies_sets = {
      for k, v in var.aws_permissions_sets : k => {
          name = v.name
          policyArn = v.policyArn
      }
      if lookup(lookup(var.aws_permissions_sets, k, tomap({ policyArn : null })), "policyArn", null) != null
  }
 # Creates a new map segregating all aws custom policies
  aws_custom_policies_sets = {
      for k, v in var.aws_permissions_sets : k => {
          name = v.name
          customPolicy = v.customPolicy
      }
      if lookup(lookup(var.aws_permissions_sets, k, tomap({ customPolicy : null })), "customPolicy", null) != null
  }
}
