variable "arm_tenant_id" { type = string }
variable "arm_client_id" { type = string }
variable "arm_client_secret" { type = string }
variable "tenant_domain" { type = string }
variable "application_single_sign_on_resource_id" { type = string }
variable "application_single_sign_on_role_id" { type = string }

variable "aws_access_key_id" { type = string }
variable "aws_secret_access_key" { type = string }
variable "aws_region" { default = "us-east-1" }
variable "aws_permissions_sets" {  }
variable "aws_accounts_permissions" { type = map(any) }

variable "role_groups" { type = map(any) }
variable "squad_groups" { type = map(any) }
variable "users" { type = map(any) }
variable "password" { type = string }
variable "tags" {
  default = {
    "Owner" = "Terraform"
  }
}
