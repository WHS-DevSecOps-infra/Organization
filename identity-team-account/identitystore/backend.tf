terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-state"
    key            = "identitystore/terraform.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "identitystore-identity-lock"
  }
}