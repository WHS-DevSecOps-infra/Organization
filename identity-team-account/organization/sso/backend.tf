terraform {
  backend "s3" {
    bucket         = "cloudfence-identity-state"
    key            = "organization/ssoadmin.tfstate"
    region         = "ap-northeast-2"
    encrypt        = true
    dynamodb_table = "ssoadmin-identity-lock"
  }
}
