terraform {
  backend "s3" {
    bucket         = "ampli-terraform-state"
    key            = "azure-sso.tfstate"
    dynamodb_table = "azure-sso"
    region         = "us-east-1"
  }
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "1.4.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
