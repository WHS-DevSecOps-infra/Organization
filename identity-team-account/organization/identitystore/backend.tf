terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-state"
    key            = "organization/identitystore.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "identitystore-identity-lock"
  }
}
