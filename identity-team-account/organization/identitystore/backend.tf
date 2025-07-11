terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-bucket"
    key            = "organization/identitystore.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "identitystore-identity-lock"
  }
}
