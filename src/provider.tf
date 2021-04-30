provider "azuread" {
  tenant_id     = var.arm_tenant_id
  client_id     = var.arm_client_id
  client_secret = var.arm_client_secret
}

provider "aws" {
  region     = var.aws_region
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
}



