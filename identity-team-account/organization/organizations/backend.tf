terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-state"
    key            = "organization/organizations.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "organizations-identity-lock"
  }
}
