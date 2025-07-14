terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0" # optional
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "ap-northeast-2"
}

data "aws_ssoadmin_instances" "this" {}

module "users" {
  for_each          = var.users
  source            = "../../../modules/identitystore_AddInstance"
  identity_store_id = data.aws_ssoadmin_instances.this.identity_store_ids[0]
  user_name         = each.key
  display_name      = each.value.display_name
  email             = each.value.email
  given_name        = each.value.given_name
  family_name       = each.value.family_name
}


output "user_ids" {
  value = {
    for k, m in module.users :
    k => m.user_id
  }
}

