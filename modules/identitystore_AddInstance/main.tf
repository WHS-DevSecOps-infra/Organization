resource "aws_identitystore_user" "this" {
  identity_store_id = var.identity_store_id
  user_name         = var.user_name
  display_name      = var.display_name

  emails {
    value   = var.email
    primary = true
  }

  name {
    given_name  = var.given_name
    family_name = var.family_name
  }
}